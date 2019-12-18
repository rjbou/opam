(**************************************************************************)
(*                                                                        *)
(*    Copyright 2012-2015 OCamlPro                                        *)
(*    Copyright 2012 INRIA                                                *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

open OpamTypes
open OpamStateTypes
open OpamPackage.Set.Op
open OpamStd.Op

module S = OpamFile.SwitchSelections

let log fmt = OpamConsole.log "SWITCH" fmt
let slog = OpamConsole.slog

let list gt ~print_short =
  log "list";
  let gt = OpamGlobalState.fix_switch_list gt in
  if print_short then
    List.iter (OpamConsole.msg "%s\n" @* OpamSwitch.to_string)
      (List.sort compare (OpamFile.Config.installed_switches gt.config))
  else
  let installed_switches =
    OpamGlobalState.fold_switches (fun sw sel acc ->
        let opams =
          OpamPackage.Set.fold (fun nv acc ->
              match
                OpamFile.OPAM.read_opt
                  (OpamPath.Switch.installed_opam gt.root sw nv)
              with
              | Some opam -> OpamPackage.Map.add nv opam acc
              | None -> acc)
            sel.sel_compiler OpamPackage.Map.empty
        in
        let ifempty default m =
          if OpamPackage.Map.is_empty m then default else m
        in
        let comp =
          OpamPackage.Map.filter
            (fun nv _ -> OpamPackage.Set.mem nv sel.sel_roots)
            opams
          |> ifempty opams
        in
        let comp =
          OpamPackage.Map.filter
            (fun _ opam -> OpamFile.OPAM.has_flag Pkgflag_Compiler opam)
            comp
          |> ifempty comp
        in
        let conf =
          OpamFile.Switch_config.read_opt
            (OpamPath.Switch.switch_config gt.root sw)
        in
        let descr = match conf with
          | Some c -> c.OpamFile.Switch_config.synopsis
          | None -> OpamConsole.colorise `red "Missing config file"
        in
        OpamSwitch.Map.add sw (OpamPackage.keys comp, descr) acc)
      gt
      OpamSwitch.Map.empty
  in
  let list = OpamSwitch.Map.bindings installed_switches in

  let table =
    List.map (OpamConsole.colorise `blue)
      ["#"; "switch"; "compiler"; "description" ] ::
    List.map (fun (switch, (packages, descr)) ->
        let current = Some switch = OpamStateConfig.get_switch_opt () in
        List.map
          (if current then OpamConsole.colorise `bold else fun s -> s)
          [ if current then
              OpamConsole.(utf8_symbol Symbols.rightwards_arrow "->")
            else "";
            OpamSwitch.to_string switch;
            OpamStd.List.concat_map ","
              (OpamConsole.colorise `yellow @* OpamPackage.to_string)
              (OpamPackage.Set.elements packages);
            descr ])
      list
  in
  OpamConsole.print_table stdout ~sep:"  "
    (OpamStd.Format.align_table table);

  match OpamStateConfig.get_switch_opt (), OpamStateConfig.(!r.switch_from)
  with
  | None, _ when OpamFile.Config.installed_switches gt.config <> [] ->
    OpamConsole.note
      "No switch is currently set, you should use 'opam switch <switch>' \
       to set an active switch"
  | Some switch, `Env ->
    let sys = OpamFile.Config.switch gt.config in
    if not (OpamGlobalState.switch_exists gt switch) then
      (OpamConsole.msg "\n";
       OpamConsole.warning
         "The OPAMSWITCH variable does not point to a valid switch: %S"
         (OpamSwitch.to_string switch))
    else if sys <> Some switch then
      (OpamConsole.msg "\n";
       OpamConsole.note
         "Current switch is set locally through the OPAMSWITCH variable.\n\
          The current global system switch is %s."
         (OpamStd.Option.to_string ~none:"unset"
            (fun s -> OpamConsole.colorise `bold (OpamSwitch.to_string s)) sys))
    else
      (match OpamStateConfig.get_current_switch_from_cwd gt.root with
       | None -> ()
       | Some sw ->
         OpamConsole.msg "\n";
         OpamConsole.note
           "Current switch is set globally and through the OPAMSWITCH variable.\n\
            Thus, the local switch found at %s was ignored."
           (OpamConsole.colorise `bold (OpamSwitch.to_string sw)))
  | Some switch, `Default when not (OpamGlobalState.switch_exists gt switch) ->
    OpamConsole.msg "\n";
    OpamConsole.warning
      "The currently selected switch (%S) is invalid.\n%s"
      (OpamSwitch.to_string switch)
      (if OpamSwitch.is_external switch
       then "Stale '_opam' directory or link ?"
       else "Fix the selection with 'opam switch set SWITCH'.")
  | Some switch, `Default when OpamSwitch.is_external switch ->
    OpamConsole.msg "\n";
    OpamConsole.note
      "Current switch has been selected based on the current directory.\n\
       The current global system switch is %s."
      (OpamStd.Option.to_string ~none:"unset"
         (fun s -> OpamConsole.colorise `bold (OpamSwitch.to_string s))
         (OpamFile.Config.switch gt.config));
    if not (OpamEnv.is_up_to_date_switch gt.root switch) then
      OpamConsole.warning
        "The environment is not in sync with the current switch.\n\
         You should run: %s"
        (OpamEnv.eval_string gt (Some switch))
  | Some switch, `Default ->
    if not (OpamEnv.is_up_to_date_switch gt.root switch) then
      (OpamConsole.msg "\n";
       OpamConsole.warning
         "The environment is not in sync with the current switch.\n\
          You should run: %s"
         (OpamEnv.eval_string gt (Some switch)))
  | _ -> ()

let clear_switch ?(keep_debug=false) gt switch =
  let module C = OpamFile.Config in
  let config = gt.config in
  let config =
    C.with_installed_switches
      (List.filter ((<>) switch) (C.installed_switches config))
      config
  in
  let config =
    if C.switch config = Some switch then C.with_switch_opt None config
    else config
  in
  let gt = { gt with config } in
  OpamGlobalState.write gt;
  let comp_dir = OpamPath.Switch.root gt.root switch in
  if keep_debug && (OpamClientConfig.(!r.keep_build_dir) || (OpamConsole.debug ())) then
    (OpamConsole.note "Keeping %s despite errors (debug mode), \
                       you may want to remove it by hand"
       (OpamFilename.Dir.to_string comp_dir);
     gt)
  else
  try OpamFilename.rmdir comp_dir; gt
  with OpamSystem.Internal_error _ -> gt

let remove gt ?(confirm = true) switch =
  log "remove switch=%a" (slog OpamSwitch.to_string) switch;
  if not (OpamGlobalState.switch_exists gt switch) then (
    OpamConsole.msg "The compiler switch %s does not exist.\n"
      (OpamSwitch.to_string switch);
    OpamStd.Sys.exit_because `Not_found;
  );
  if not confirm ||
     OpamConsole.confirm
       "Switch %s and all its packages will be wiped. Are you sure?"
       (OpamSwitch.to_string switch)
  then
    clear_switch gt switch
  else gt

let set_invariant_raw st invariant =
  let switch_config = {st.switch_config with invariant} in
  let st = {st with switch_invariant = invariant; switch_config } in
  if not (OpamStateConfig.(!r.dryrun) || OpamClientConfig.(!r.show)) then
    OpamSwitchAction.install_switch_config st.switch_global.root st.switch
      switch_config;
  st

let install_compiler ?(additional_installs=[]) ?(deps_only=false) t =
  let invariant = t.switch_invariant in
  if invariant = OpamFormula.Empty && additional_installs = [] then begin
    (if not OpamClientConfig.(!r.show) &&
        not OpamStateConfig.(!r.dryrun) then
       OpamFile.Environment.write (OpamPath.Switch.environment t.switch_global.root t.switch) (OpamEnv.compute_updates t);
     OpamEnv.check_and_print_env_warning t);
    t
  end else
  let atoms = OpamFormula.atoms invariant in
  let names_of_atoms at = OpamPackage.Name.Set.of_list (List.map fst at) in
  let comp_roots = names_of_atoms atoms in
  let add_names = names_of_atoms additional_installs in
  let roots =
    OpamPackage.Name.Set.union comp_roots add_names
  in
  OpamConsole.header_msg "Installing new switch packages";
  OpamConsole.msg "Switch invariant: %s\n"
    (OpamFileTools.dep_formula_to_string invariant);
  (* let not_found =
   *   OpamPackage.Name.Set.diff roots @@
   *   OpamPackage.names_of_packages @@
   *   OpamPackage.packages_of_names t.packages roots
   * in
   * if not (OpamPackage.Name.Set.is_empty not_found) then
   *   OpamConsole.error_and_exit `Not_found
   *     "No packages %s found."
   *     (OpamPackage.Name.Set.to_string not_found); *)
  let solution =
    OpamSolution.resolve t Switch
      ~orphans:OpamPackage.Set.empty
      ~requested:roots
      (OpamSolver.request ~install:additional_installs ())
  in
  let solution = match solution with
    | Success s -> s
    | Conflicts cs ->
      OpamConsole.error_and_exit `No_solution
        "Could not resolve base install for this switch:\n%s"
        (OpamCudf.string_of_conflict t.packages
           (OpamSwitchState.unavailable_reason t) cs);
  in
  let () = match OpamSolver.stats solution with
    | { s_install = _; s_reinstall = 0; s_upgrade = 0;
        s_downgrade=0; s_remove = 0 } -> ()
    | stats ->
      OpamConsole.error_and_exit `No_solution
        "Inconsistent resolution of base package installs:\n%s"
        (OpamSolver.string_of_stats stats)
  in
  let to_install_pkgs = OpamSolver.new_packages solution in
  let base_comp = OpamPackage.packages_of_names to_install_pkgs comp_roots in
  let non_comp =
    OpamPackage.Set.filter
      (fun nv ->
         not (OpamFile.OPAM.has_flag Pkgflag_Compiler
                (OpamSwitchState.opam t nv)))
      base_comp
  in
  if not (OpamPackage.Set.is_empty non_comp) &&
     not (OpamConsole.confirm ~default:false
            "Packages %s don't have the 'compiler' flag set. Are you sure you \
             want to define them as the invariant base for this switch?"
            (OpamStd.List.concat_map ", " OpamPackage.to_string
               (OpamPackage.Set.elements non_comp)))
  then
    OpamConsole.error_and_exit `Aborted
      "Aborted installation of non-compiler packages \
       as switch base.";
  let t =
    if t.switch_config.OpamFile.Switch_config.synopsis = "" then
      let synopsis =
        match OpamPackage.Set.elements base_comp with
        | [] -> OpamSwitch.to_string t.switch
        | [pkg] ->
          let open OpamStd.Option.Op in
          (OpamSwitchState.opam_opt t pkg >>= OpamFile.OPAM.synopsis) +!
          OpamPackage.to_string pkg
        | pkgs -> OpamStd.List.concat_map " " OpamPackage.to_string pkgs
      in
      let switch_config =
        { t.switch_config with OpamFile.Switch_config.synopsis }
      in
      if not (OpamStateConfig.(!r.dryrun) || OpamClientConfig.(!r.show)) then
        OpamSwitchAction.install_switch_config t.switch_global.root t.switch
          switch_config;
      { t with switch_config }
    else t
  in
  let t = { t with compiler_packages = base_comp } in
  let solution =
    if deps_only then
      OpamSolver.filter_solution (fun nv ->
          not (OpamPackage.Name.Set.mem nv.name add_names))
        solution
    else solution
  in
  let ask =
    OpamClientConfig.(!r.show) || additional_installs <> []
  in
  let t, result =
    OpamSolution.apply t
      ~ask
      ~requested:roots
      ~add_roots:roots
      solution in
  OpamSolution.check_solution ~quiet:OpamClientConfig.(not !r.show) t
    (Success result);
  t

let create
    gt ~rt ?synopsis ?repos ~update_config ~invariant switch post =
  let update_config = update_config && not (OpamSwitch.is_external switch) in
  let comp_dir = OpamPath.Switch.root gt.root switch in
  if OpamGlobalState.switch_exists gt switch then
    OpamConsole.error_and_exit `Bad_arguments
      "There already is an installed switch named %s"
      (OpamSwitch.to_string switch);
  if Sys.file_exists (OpamFilename.Dir.to_string comp_dir) then
    OpamConsole.error_and_exit `Bad_arguments
      "Directory %S already exists, please choose a different name"
      (OpamFilename.Dir.to_string comp_dir);
  let st =
    if not (OpamStateConfig.(!r.dryrun) || OpamClientConfig.(!r.show)) then
      let gt =
        OpamSwitchAction.create_empty_switch gt ?synopsis ?repos ~invariant
          switch
      in
      if update_config then
        OpamSwitchAction.set_current_switch `Lock_write gt ~rt switch
      else
      let rt =
        ({ rt with repos_global = (gt :> unlocked global_state)  }
         :> unlocked repos_state)
      in
      OpamSwitchState.load `Lock_write gt rt switch
    else
      let rt = (rt :> unlocked repos_state) in
      let st = OpamSwitchState.load_virtual ?repos_list:repos gt rt in
      let switch_config =
        OpamSwitchAction.gen_switch_config gt.root ?repos switch ~invariant
      in
      let st = { st with switch_invariant = invariant } in
      let available_packages =
        lazy (OpamSwitchState.compute_available_packages gt switch switch_config
                ~pinned:OpamPackage.Set.empty
                ~opams:st.opams)
      in
      { st with switch; switch_config; available_packages }
  in
  OpamGlobalState.drop gt;
  try post st
  with e when not (OpamStateConfig.(!r.dryrun) || OpamClientConfig.(!r.show)) ->
    let () =
      try OpamStd.Exn.fatal e with e ->
        OpamStd.Exn.finalise e @@ fun () ->
        OpamConsole.warning "Switch %s left partially installed"
          (OpamSwitch.to_string st.switch)
    in
    OpamStd.Exn.finalise e @@ fun () ->
    if OpamConsole.confirm "Switch initialisation failed: clean up? \
                            ('n' will leave the switch partially installed)"
    then
      let gt, switch = st.switch_global, st.switch in
      OpamSwitchState.drop st;
      OpamGlobalState.drop (clear_switch gt switch)


let switch lock gt switch =
  log "switch switch=%a" (slog OpamSwitch.to_string) switch;
  if OpamGlobalState.switch_exists gt switch then
    OpamRepositoryState.with_ `Lock_none gt @@ fun rt ->
    let st =
      if not (OpamStateConfig.(!r.dryrun) || OpamClientConfig.(!r.show)) then
        OpamSwitchAction.set_current_switch lock gt ~rt switch
      else
        OpamSwitchState.load lock gt rt switch
    in
    OpamEnv.check_and_print_env_warning st
  else
  let installed_switches = OpamFile.Config.installed_switches gt.config in
  OpamConsole.error_and_exit `Not_found
    "No switch %s is currently installed. Did you mean \
     'opam switch create %s'?\n\
     Installed switches are:\n%s"
    (OpamSwitch.to_string switch) (OpamSwitch.to_string switch)
    (OpamStd.Format.itemize OpamSwitch.to_string installed_switches)

let import_t ?ask importfile t =
  log "import switch";

  let import_sel = importfile.OpamFile.SwitchExport.selections in
  let import_opams = importfile.OpamFile.SwitchExport.overlays in

  let opams =
    OpamPackage.Name.Map.fold (fun name opam opams ->
        let nv = OpamPackage.create name (OpamFile.OPAM.version opam) in
        OpamPackage.Map.add nv opam opams)
      import_opams t.opams
  in

  let packages = t.packages ++ OpamPackage.keys opams in

  let pinned =
    let names = OpamPackage.names_of_packages import_sel.sel_pinned in
    OpamPackage.Set.filter
      (fun nv -> not (OpamPackage.Name.Set.mem nv.name names)) t.pinned ++
    import_sel.sel_pinned
  in

  let available =
    OpamSwitchState.compute_available_packages
      t.switch_global t.switch t.switch_config
      ~pinned ~opams
  in

  let compiler_packages, to_install =
    if OpamPackage.Set.is_empty t.compiler_packages then
      import_sel.sel_compiler %% available,
      import_sel.sel_installed
    else
      t.compiler_packages,
      import_sel.sel_installed -- import_sel.sel_compiler
  in

  let t =
    { t with
      available_packages = lazy available;
      packages;
      compiler_packages;
      pinned;
      opams; }
  in

  let unavailable_version, unavailable =
    let available_names = OpamPackage.names_of_packages available in
    OpamPackage.Set.partition
      (fun nv -> OpamPackage.Name.Set.mem nv.name available_names)
      (to_install -- available)
  in

  if not (OpamPackage.Set.is_empty unavailable_version) then
    OpamConsole.warning
      "These packages aren't available at the specified versions, \
       version constraints have been discarded:\n%s"
      (OpamStd.Format.itemize OpamPackage.to_string
         (OpamPackage.Set.elements unavailable_version));
  if not (OpamPackage.Set.is_empty unavailable) then
    OpamConsole.warning
      "These packages are unavailable, they have been ignored from \
       the import file:\n%s"
      (OpamStd.Format.itemize OpamPackage.to_string
         (OpamPackage.Set.elements unavailable));

  let t, solution =
    let to_import =
      OpamSolution.eq_atoms_of_packages (to_install %% available) @
      OpamSolution.atoms_of_packages unavailable_version
    in

    let add_roots = OpamPackage.names_of_packages import_sel.sel_roots in

    OpamSolution.resolve_and_apply ?ask t Import
      ~requested:(OpamPackage.Name.Set.of_list @@ List.map fst to_import)
      ~add_roots
      ~orphans:OpamPackage.Set.empty
      { wish_install = to_import;
        wish_remove  = [];
        wish_upgrade = [];
        criteria = `Default;
        extra_attributes = []; }
  in
  OpamSolution.check_solution t solution;
  if not (OpamStateConfig.(!r.dryrun) || OpamClientConfig.(!r.show))
  then begin
    (* Put imported overlays in place *)
    OpamPackage.Set.iter (fun nv ->
        match OpamPackage.Name.Map.find_opt nv.name import_opams with
        | None -> ()
        | Some opam ->
          OpamFilename.rmdir
            (OpamPath.Switch.Overlay.package t.switch_global.root
               t.switch nv.name);
          OpamFile.OPAM.write
            (OpamPath.Switch.Overlay.opam t.switch_global.root
               t.switch nv.name)
            opam)
      pinned;
    (* Save new pinnings *)
    let sel = OpamSwitchState.load_selections t.switch_global t.switch in
    S.write
      (OpamPath.Switch.selections t.switch_global.root t.switch)
      { sel with sel_pinned = pinned }
  end;
  t

let read_overlays (read: package -> OpamFile.OPAM.t option) packages =
  OpamPackage.Set.fold (fun nv acc ->
      match read nv with
      | Some opam ->
        if OpamFile.OPAM.extra_files opam <> None then
          (OpamConsole.warning
             "Metadata of package %s uses a files%s subdirectory, it may not be \
              re-imported correctly (skipping definition)"
             (OpamPackage.to_string nv) Filename.dir_sep;
           acc)
        else OpamPackage.Name.Map.add nv.name opam acc
      | None -> acc)
    packages
    OpamPackage.Name.Map.empty

let export ?(full=false) filename =
  let switch = OpamStateConfig.get_switch () in
  let root = OpamStateConfig.(!r.root_dir) in
  let export =
    OpamFilename.with_flock `Lock_none (OpamPath.Switch.lock root switch)
    @@ fun _ ->
    let selections = S.safe_read (OpamPath.Switch.selections root switch) in
    let overlays =
      read_overlays (fun nv ->
          OpamFileTools.read_opam
            (OpamPath.Switch.Overlay.package root switch nv.name))
        selections.sel_pinned
    in
    let overlays =
      if full then
        OpamPackage.Name.Map.union (fun a _ -> a) overlays @@
        read_overlays (fun nv ->
            OpamFile.OPAM.read_opt
              (OpamPath.Switch.installed_opam root switch nv))
          (selections.sel_installed -- selections.sel_pinned)
      else overlays
    in
    { OpamFile.SwitchExport.selections; overlays }
  in
  match filename with
  | None   -> OpamFile.SwitchExport.write_to_channel stdout export
  | Some f -> OpamFile.SwitchExport.write f export

let show () =
  OpamConsole.msg "%s\n"
    (OpamSwitch.to_string (OpamStateConfig.get_switch ()))

let reinstall init_st =
  let switch = init_st.switch in
  log "reinstall switch=%a" (slog OpamSwitch.to_string) switch;
  let gt = init_st.switch_global in

  let switch_root = OpamPath.Switch.root gt.root switch in
  let opam_subdir = OpamPath.Switch.meta gt.root switch in
  let pkg_dirs =
    List.filter ((<>) opam_subdir) (OpamFilename.dirs switch_root)
  in
  List.iter OpamFilename.cleandir pkg_dirs;
  List.iter OpamFilename.remove (OpamFilename.files switch_root);
  OpamFilename.cleandir (OpamPath.Switch.config_dir gt.root switch);
  OpamFilename.cleandir (OpamPath.Switch.installed_opams gt.root switch);
  let st =
    { init_st with
      installed = OpamPackage.Set.empty;
      installed_roots = OpamPackage.Set.empty;
      reinstall = lazy OpamPackage.Set.empty; }
  in
  import_t { OpamFile.SwitchExport.
             selections = OpamSwitchState.selections init_st;
             overlays = OpamPackage.Name.Map.empty; }
    st

let import st filename =
  let import_str = match filename with
    | None   -> OpamSystem.string_of_channel stdin
    | Some f -> OpamFilename.read (OpamFile.filename f)
  in
  let importfile =
    try OpamFile.SwitchExport.read_from_string ?filename import_str
    with OpamPp.Bad_format _ as e ->
      log "Error loading export file, trying the old file format";
      try
        let selections = OpamFile.LegacyState.read_from_string import_str in
        { OpamFile.SwitchExport.selections;
          overlays = OpamPackage.Name.Map.empty }
      with e1 -> OpamStd.Exn.fatal e1; raise e
  in
  import_t importfile st

let set_invariant ?(force=false) st invariant =
  let satisfied = OpamFormula.satisfies_depends st.installed invariant in
  let names =
    OpamPackage.Name.Set.of_list (List.map fst (OpamFormula.atoms invariant))
  in
  let name_unknown =
    OpamPackage.Name.Set.filter
      (fun n -> not (OpamPackage.has_name st.packages n))
      names
  in
  if not (OpamPackage.Name.Set.is_empty name_unknown) then
    (if satisfied || force then OpamConsole.warning
     else OpamConsole.error_and_exit `Not_found)
      "No packages by these names found: %s"
      (OpamStd.List.concat_map ", "
         OpamPackage.Name.to_string
         (OpamPackage.Name.Set.elements name_unknown));
  let packages = OpamFormula.packages st.installed invariant in
  let not_comp =
    OpamPackage.Set.filter (fun nv ->
        match OpamSwitchState.opam_opt st nv with
        | Some opam -> OpamFile.OPAM.has_flag Pkgflag_Compiler opam
        | None -> false)
      packages
  in
  if not (OpamPackage.Set.is_empty not_comp) then
    OpamConsole.warning
      "Packages %s don't have the 'compiler' flag set."
      (OpamStd.Format.pretty_list
         (List.map OpamPackage.Name.to_string
            (OpamPackage.Name.Set.elements
               (OpamPackage.names_of_packages not_comp))));
  set_invariant_raw st invariant

let get_compiler_packages ?repos rt =
  let repos = match repos with
    | None -> OpamGlobalState.repos_list rt.repos_global
    | Some r -> r
  in
  let package_index = OpamRepositoryState.build_index rt repos in
  OpamPackage.Map.filter
    (fun _ opam ->
       OpamFile.OPAM.has_flag Pkgflag_Compiler opam &&
       OpamFilter.eval_to_bool ~default:false
         (OpamPackageVar.resolve_global rt.repos_global)
         (OpamFile.OPAM.available opam))
    package_index
  |> OpamPackage.keys

let guess_compiler_invariant ?repos rt strings =
  let repos = match repos with
    | None -> OpamGlobalState.repos_list rt.repos_global
    | Some r -> r
  in
  let opams = OpamRepositoryState.build_index rt repos  in
  let packages = OpamPackage.keys opams in
  let compiler_packages =
    OpamPackage.Map.filter
      (fun _ -> OpamFile.OPAM.has_flag Pkgflag_Compiler)
      opams
    |> OpamPackage.keys
  in
  let invariant =
    List.fold_left (fun acc str ->
        try
          let (name, _) as atom = OpamFormula.atom_of_string str in
          if OpamPackage.Set.exists (OpamFormula.check atom)
              (OpamPackage.packages_of_name packages name)
          then OpamFormula.ands [acc; Atom atom]
          else raise Not_found
        with Failure _ | Not_found ->
        try
          let v = OpamPackage.Version.of_string str in
          let candidates =
            OpamPackage.Set.filter (fun nv -> nv.version = v)
              compiler_packages
          in
          if OpamPackage.Set.is_empty candidates then
            raise Not_found
          else
          let disj =
            OpamPackage.Set.fold
              (fun nv acc ->
                 OpamFormula.ors
                   [acc; Atom (OpamSolution.eq_atom_of_package nv)])
              candidates OpamFormula.Empty
          in
          OpamFormula.ands [acc; disj]
        with
        | Failure _ ->
          OpamConsole.error_and_exit `Bad_arguments
            "Invalid package specification or version %S"
            str
        | Not_found ->
          OpamConsole.error_and_exit `Not_found
            "No compiler matching `%s' found, use `opam switch list-available' \
             to see what is available, or use `--packages' to select packages \
             explicitly."
            str)
      OpamFormula.Empty
      strings
  in
  OpamFormula.of_atom_formula invariant
