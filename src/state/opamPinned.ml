(**************************************************************************)
(*                                                                        *)
(*    Copyright 2012-2019 OCamlPro                                        *)
(*    Copyright 2012 INRIA                                                *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

open OpamTypes
open OpamStateTypes
open OpamFilename.Op
open OpamStd.Option.Op

let log fmt = OpamConsole.log "PIN" fmt

let package st name = OpamPackage.package_of_name st.pinned name

let package_opt st name = try Some (package st name) with Not_found -> None

let version st name = (package st name).version

let packages st = st.pinned

let possible_definition_filenames dir name = [
  dir / (OpamPackage.Name.to_string name ^ ".opam") // "opam";
  dir // (OpamPackage.Name.to_string name ^ ".opam");
  dir / "opam" / (OpamPackage.Name.to_string name ^ ".opam") // "opam";
  dir / "opam" // (OpamPackage.Name.to_string name ^ ".opam");
  dir / "opam" // "opam";
  dir // "opam"
]

let lock_filename file =
  OpamStateConfig.(!r.locked)
  >>| OpamFilename.add_extension file

let check_locked default =
  match lock_filename default with
  | None -> default
  | Some locked ->
    if not (OpamFilename.exists locked) then default else
      (log "Lock file found %s" (OpamFilename.to_string default);
       let base_depends =
         OpamFile.make default
         |> OpamFile.OPAM.read
         |> OpamFile.OPAM.depends
       in
       let lock_depends =
         OpamFile.make locked
         |> OpamFile.OPAM.read
         |> OpamFile.OPAM.depends
       in
       let ldep_names =
         OpamFormula.fold_left
           (fun acc (n,_) -> OpamPackage.Name.Set.add n acc)
           OpamPackage.Name.Set.empty lock_depends
       in
       let base_formula =
         OpamFilter.filter_deps ~build:true ~post:true ~test:false ~doc:false
           ~dev:false base_depends
       in
       let lock_formula =
         OpamFilter.filter_deps ~build:true ~post:true ~test:false ~doc:false
           ~dev:false lock_depends
       in
       let lpkg_f =
         lock_formula
         |> OpamFormula.atoms
         |> OpamPackage.Name.Map.of_list
       in
       (* Check consistency between them. It is based on the fact that locked file
          dependencies are an and list with precise version, i.e., pkg { =v0.1}.
          Construction of a two list: missing dependencies and inconsistent ones
          (version mismatch) *)
       let (@) = List.rev_append in
       let rec fold formula =
         List.fold_left cross ([],[]) (OpamFormula.ands_to_list formula)
       and cross (cont,cons) formula =
         match formula with
         | Atom (bn, bvf) ->
           ( let cont =
               if OpamPackage.Name.Set.mem bn ldep_names then cont
               else bn::cont
             in
             let cons =
               match OpamPackage.Name.Map.find_opt bn lpkg_f with
               | Some (Some (`Eq, lv)) ->
                 if OpamFormula.check_version_formula bvf lv then cons
                 else (bn, lv, bvf)::cons
               | _ -> cons
             in
             (cont,cons))
         | Or (or1, or2) ->
           let or1_cont, or1_cons = fold or1 in
           let or2_cont, or2_cons = fold or2 in
           let cont =
             if or1_cont = [] || or2_cont = [] then cont
             else or1_cont @ or2_cont @ cont
           in
           let cons =
             if or1_cons = [] || or2_cons = [] then cons
             else or1_cons @ or2_cons @ cons
           in
           (cont,cons)
         | And (and1, and2) ->
           let and1_cont, and1_cons = fold and1 in
           let and2_cont, and2_cons = fold and2 in
           ((and1_cont @ and2_cont @ cont), (and1_cons @ and2_cons @ cons))
         | Block f -> cross (cont,cons) f
         | Empty -> (cont,cons)
       in
       let contains, consistent = fold base_formula in
       if contains <> [] || consistent <> [] then
         (OpamConsole.warning "Lock file %s is outdated, you may want to re-run opam lock:\n%s"
            (OpamConsole.colorise `underline (OpamFilename.Base.to_string (OpamFilename.basename locked)))
            ((if contains <> [] then
                Printf.sprintf "Dependencies present in opam file not in lock file:\n%s"
                  (OpamStd.Format.itemize OpamPackage.Name.to_string contains)
              else "")
             ^
             (if consistent <> [] then
                Printf.sprintf "Dependencies in lock file not consistent wit opam file filter:\n%s"
                  (OpamStd.Format.itemize (fun (n,lv,(bv: OpamFormula.version_formula)) ->
                       Printf.sprintf "%s: %s in not contained in {%s}"
                         (OpamPackage.Name.to_string n)
                         (OpamPackage.Version.to_string lv)
                         (OpamFormula.string_of_formula
                            (fun (op, vc) ->
                               Printf.sprintf "%s %s"
                                 (OpamPrinter.FullPos.relop_kind op) (OpamPackage.Version.to_string vc))
                            bv))
                      consistent)
              else "")));
       locked)

let find_opam_file_in_source ?(locked=false) name dir =
  let opt =
    OpamStd.List.find_opt OpamFilename.exists
      (possible_definition_filenames dir name)
  in
  (match opt with
   | Some base when locked -> Some (check_locked base)
   | _ -> opt)
  |> OpamStd.Option.map OpamFile.make

let find_lock_file_in_source name dir =
  OpamStateConfig.(!r.locked) >>= (fun ext ->
      let definitions =
        List.map (fun f -> OpamFilename.add_extension f ext)
          (possible_definition_filenames dir name)
      in
      OpamStd.List.find_opt OpamFilename.exists definitions)
  >>| OpamFile.make

let name_of_opam_filename ?(locked=false) dir file =
  let suffix =
    let suff = ".opam" in
    if locked then
      (OpamStateConfig.(!r.locked) >>| Printf.sprintf "%s.%s" suff)
      +! suff
    else suff
  in
  let get_name s =
    if Filename.check_suffix s suffix
    then Some Filename.(chop_suffix (basename s) suffix)
    else None
  in
  let rel = OpamFilename.remove_prefix dir file in
  let rel =
    match OpamStateConfig.(!r.locked) with
    | None -> rel
    | Some suf ->
      let ext = "."^suf in
      if OpamStd.String.ends_with ~suffix:(suffix^ext) rel then
        OpamStd.String.remove_suffix ~suffix:ext rel
      else rel
  in
  (get_name (Filename.basename rel) >>+ fun () ->
   get_name (Filename.dirname rel)) >>= fun name ->
  try Some (OpamPackage.Name.of_string name)
  with Failure _ -> None

let files_in_source ?(recurse=false) ?subpath ?(locked=false) d =
  let baseopam = OpamFilename.Base.of_string "opam" in
  let files =
    let rec files_aux acc base d =
      let acc =
        OpamStd.List.filter_map (fun f ->
            if OpamFilename.basename f = baseopam ||
               OpamFilename.check_suffix f ".opam" then
              let base =
                match base, subpath with
                | Some b, Some sp -> Some (Filename.concat sp b)
                | Some b, _ | _, Some b -> Some b
                | None, None -> None
              in
              Some (f, base)
            else
              None)
          (OpamFilename.files d) @ acc
      in
      List.fold_left
        (fun acc d ->
           if OpamFilename.(basename_dir d = Base.of_string "opam") ||
              OpamStd.String.ends_with ~suffix:".opam"
                (OpamFilename.Dir.to_string d)
           then
             match OpamFilename.opt_file OpamFilename.Op.(d//"opam") with
             | None -> acc
             | Some f -> (f, base) :: acc
           else
           let base_dir = OpamFilename.basename_dir d in
           let basename = OpamFilename.Base.to_string base_dir in
           if recurse &&
              not (base_dir = OpamFilename.Base.of_string OpamSwitch.external_dirname ||
                   base_dir = OpamFilename.Base.of_string "_build" ||
                   OpamStd.String.starts_with ~prefix:"." basename)
           then
             let base = match base with
               | None -> Some basename
               | Some base -> Some (Filename.concat base basename) in
             files_aux acc base d
           else
             acc)
        acc (OpamFilename.dirs d)
    in
    files_aux [] None
  in
  let d =
    (OpamStd.Option.map_default (fun sp -> OpamFilename.Op.(d / sp)) d subpath)
  in
  files d @ files (d / "opam") |>
  List.map (fun (f,s) -> (if locked then check_locked f else f), s) |>
  OpamStd.List.filter_map
    (fun (f, subpath) ->
       try
         (* Ignore empty files *)
         if (Unix.stat (OpamFilename.to_string f)).Unix.st_size = 0 then None
         else Some (name_of_opam_filename d f, OpamFile.make f, subpath)
       with Unix.Unix_error _ ->
         OpamConsole.error "Can not read %s, ignored."
           (OpamFilename.to_string f);
         None)

let orig_opam_file st name ?(locked=false) opam =
  let open OpamStd.Option.Op in
  OpamFile.OPAM.get_metadata_dir
    ~repos_roots:(OpamRepositoryState.get_root st.switch_repos)
    opam >>= fun dir ->
  (* why not possible_definition_filenames ? *)
  let opam_files = [
    dir // (OpamPackage.Name.to_string name ^ ".opam");
    dir // "opam"
  ] in
  let locked_files =
    if locked then OpamStd.List.filter_map lock_filename opam_files else []
  in
  OpamStd.List.find_opt OpamFilename.exists locked_files
  ++ OpamStd.List.find_opt OpamFilename.exists opam_files
  >>| OpamFile.make

let save_overlay st name ?version urlf opam =
  log "saving overlay for %s" (OpamPackage.Name.to_string name);
  let version =
      version
      ++ OpamFile.OPAM.version_opt opam
      +! OpamPackage.Version.default
  in
  let root = st.switch_global.root in
  let overlay_dir = OpamPath.Switch.Overlay.package root st.switch name in
  OpamFilename.mkdir overlay_dir;
  let opam_file = OpamPath.Switch.Overlay.opam root st.switch name in
  List.iter OpamFilename.remove
    OpamPath.Switch.Overlay.([
        OpamFile.filename opam_file;
        OpamFile.filename (url root st.switch name);
        OpamFile.filename (descr root st.switch name);
      ]);
  let files_dir = OpamPath.Switch.Overlay.files root st.switch name in
  OpamFilename.rmdir files_dir;
  let opam =
    OpamFile.OPAM.with_name name opam
    |> OpamFile.OPAM.with_version version
    |> OpamFile.OPAM.with_url urlf
  in
  List.iter (fun (file, rel_file, hash) ->
      if OpamFilename.exists file &&
         OpamHash.check_file (OpamFilename.to_string file) hash then
        OpamFilename.copy ~src:file
          ~dst:(OpamFilename.create files_dir rel_file)
      else
        OpamConsole.warning "Ignoring file %s with invalid hash"
          (OpamFilename.to_string file))
    (OpamFile.OPAM.get_extra_files
       ~repos_roots:(OpamRepositoryState.get_root st.switch_repos)
       opam);
  OpamFile.OPAM.write opam_file
    (OpamFile.OPAM.with_extra_files_opt None opam);
  opam
