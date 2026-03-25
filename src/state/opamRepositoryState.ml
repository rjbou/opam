(**************************************************************************)
(*                                                                        *)
(*    Copyright 2012-2020 OCamlPro                                        *)
(*    Copyright 2012 INRIA                                                *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

open OpamTypes
open OpamStateTypes

let log ?level fmt = OpamConsole.log ?level "RSTATE" fmt
let slog = OpamConsole.slog

module Cache = struct
  type t = {
    cached_repofiles: (repository_name * OpamFile.Repo.t) list;
    cached_opams: (repository_name * OpamFile.OPAM.t OpamPackage.Map.t) list;
  }

  module C = OpamCached.Make (struct
      type nonrec t = t
      let name = "repository"
    end)

  let remove () =
    let root = OpamStateConfig.(!r.root_dir) in
    let cache_dir = OpamPath.state_cache_dir root in
    let remove_cache_file file =
      if OpamFilename.check_suffix file ".cache" then
        OpamFilename.remove file
    in
    List.iter remove_cache_file (OpamFilename.files cache_dir)

  let marshall rt =
    (* Repository without remote are not cached, they are intended to be
       manually edited *)
    let filter_out_nourl repos_map =
      OpamRepositoryName.Map.filter
        (fun name _ ->
           try
             (OpamRepositoryName.Map.find name rt.repositories).repo_url <>
             OpamUrl.empty
           with Not_found -> false)
        repos_map
    in
      { cached_repofiles =
          OpamRepositoryName.Map.bindings
            (filter_out_nourl rt.repos_definitions);
        cached_opams =
          OpamRepositoryName.Map.bindings
            (filter_out_nourl rt.repo_opams);
      }

  let file rt =
    OpamPath.state_cache rt.repos_global.root

  let save rt =
    remove ();
    C.save (file rt) (marshall rt)

  let save_new rt =
    C.save (file rt) (marshall rt)

  let load root =
    let file = OpamPath.state_cache root in
    match C.load file with
    | Some cache ->
      Some
        (OpamRepositoryName.Map.of_list cache.cached_repofiles,
         OpamRepositoryName.Map.of_list cache.cached_opams)
    | None -> None

end

let get_root_raw root name =
  let tar = OpamRepositoryPath.tar root name in
  if OpamRepositoryRoot.Tar.exists tar then
    OpamRepositoryRoot.Tar tar
  else
    OpamRepositoryRoot.Dir (OpamRepositoryPath.root root name)

let get_root rt name =
  get_root_raw rt.repos_global.root name

let get_repo_root rt repo =
  get_root_raw rt.repos_global.root repo.repo_name

let get_repo_files rt name dir =
  let tdebug = false in
  match get_root rt name with
  | OpamRepositoryRoot.Tar tar ->
    if tdebug then
      OpamConsole.error "RS: GET REPO FIULES Tar";
    let xfiles_dir =
      let open OpamFilename.Op in
      OpamFilename.raw_dir (*(OpamRepositoryName.to_string name)
                             /  *) dir
    in
    if tdebug then
      OpamConsole.error "RS:GRF: xfiles dir %s"
        (OpamFilename.Dir.to_string xfiles_dir);
    OpamTar.fold_reg_files (fun acc filename_s content ->
        let filename =
          let open OpamFilename.Op in
          (*OpamFilename.raw_dir (OpamRepositoryName.to_string name)
          //*) OpamFilename.raw filename_s
        in
        if tdebug then
          OpamConsole.error "RS:GRF: starts with lookup %B %s"
            (OpamFilename.starts_with xfiles_dir filename)
            (OpamFilename.to_string filename);
        if OpamFilename.starts_with xfiles_dir filename then
          let content = lazy (
            log ~level:5 "read %s"
              OpamFilename.Op.(
                OpamFilename.to_string
                  (OpamFilename.raw_dir (OpamRepositoryName.to_string name)
                   // filename_s));
            content)
          in
          let basename =
            filename
            |> OpamFilename.remove_prefix xfiles_dir
            |> OpamFilename.Base.of_string
          in
          (basename, content)::acc
        else acc)
      [] (OpamRepositoryRoot.Tar.to_file tar)
  | OpamRepositoryRoot.Dir repo_root ->
    if tdebug then
      OpamConsole.error "RS:GRF: GET REPO FIULES DIR";
    let dir = OpamRepositoryRoot.Dir.Op.(repo_root / dir) in
    let files = OpamFilename.rec_files dir in
    if tdebug then
      OpamConsole.error "RS:GRF: dir %s\nfiles %s"
        (OpamFilename.Dir.to_string dir)
        (OpamStd.List.to_string OpamFilename.to_string files);
    List.map (fun file ->
        OpamFilename.Base.of_string
          (OpamSystem.back_to_forward (OpamFilename.remove_prefix dir file)),
        lazy (OpamFilename.read file))
      files

let read_package_opam_dir ~repo_name ~repo_root package_dir =
  match OpamFileTools.read_repo_opam_dir ~repo_name ~repo_root package_dir with
  | Some opam ->
    (try
       let nv =
         OpamPackage.of_string
           (OpamFilename.Base.to_string (OpamFilename.basename_dir package_dir))
       in
       Some (nv, opam)
     with Failure _ ->
       log "ERR: directory name not a valid package: ignored %s"
         (OpamFilename.to_string OpamFilename.Op.(package_dir // "opam"));
       None)
  | None ->
    log "ERR: Could not load %s, ignored"
      (OpamFilename.to_string OpamFilename.Op.(package_dir // "opam"));
    None

let read_package_opam_tar ~repo_name ~repo_root package_dir filename content extrafiles =
  match OpamFileTools.read_repo_opam_tar ~repo_name ~repo_root
          package_dir filename content extrafiles with
  | Some opam ->
    (try
       let nv =
         OpamPackage.of_string
           (OpamFilename.Base.to_string (OpamFilename.basename_dir package_dir))
       in
       Some (nv, opam)
     with Failure _ ->
       log "ERR: directory name not a valid package: ignored %s"
         (OpamFilename.to_string OpamFilename.Op.(package_dir // "opam"));
       None)
  | None ->
    log "ERR: Could not load %s, ignored"
      (OpamFilename.to_string OpamFilename.Op.(package_dir // "opam"));
    None

let load_raw_opams_and_aux_from_tar repo_name tar =
  let tdebug = false in
  let raw_repository =
    OpamTar.fold_reg_files (fun acc filename content ->
        (filename, content) :: acc) []
      (OpamRepositoryRoot.Tar.to_file tar)
  in
  let repo_def =
    (* TAR TODO with root url ? *)
    let filename = "repo" in
    match List.assoc_opt filename raw_repository with
    | Some content ->
      let filename =
        let open OpamFilename.Op in
        OpamFile.make
          (OpamFilename.raw_dir ("["^OpamRepositoryName.to_string repo_name^"]")
           // filename)
      in
      let _ = log ~level:5 "read %s" (OpamFilename.to_string (OpamFile.filename filename)) in
      OpamFile.Repo.safe_read_from_string ~filename content
    | None -> OpamFile.Repo.empty
  in
  let raw_repository = List.map (fun (f,c) -> OpamFilename.raw f, c) raw_repository in
  if tdebug then
    OpamConsole.error "raw repo\n%s"
      (OpamStd.Format.itemize (fun (f,_) -> OpamFilename.to_string f) raw_repository);
  let opams_map =
    List.fold_left (fun acc (filename, content) ->
        if OpamFilename.basename filename = OpamFilename.Base.of_string "opam" then
          let key = OpamFilename.dirname filename in
          let value = filename, content, OpamFilename.Map.empty in
          OpamFilename.Dir.Map.add key value acc
        else acc)
      OpamFilename.Dir.Map.empty raw_repository
  in
  if tdebug then
    OpamConsole.error "RS:LOXA: fst opams_map\n%s"
      (OpamStd.Format.itemize OpamFilename.Dir.to_string
         (OpamFilename.Dir.Map.keys opams_map));
  let opams_map =
    let exception Found of
        OpamFilename.Dir.t
        * (OpamFilename.t * string * string OpamFilename.Map.t)
    in
    List.fold_left (fun acc (filename, content) ->
        try
          OpamFilename.Dir.Map.iter (fun dir value ->
              if tdebug then
                OpamConsole.error "RS:LOXA: dir %s is prefix ? %B"
                  (OpamFilename.Dir.to_string dir)
                  (OpamFilename.starts_with dir filename);
              if OpamFilename.starts_with dir filename then
                raise (Found (dir, value))
            ) acc;
          (* TAR TODO skipping msg ? *)
          acc
        with Found (key, value) ->
          let fo, co, map = value in
          let map = OpamFilename.Map.add filename content map in
          OpamFilename.Dir.Map.add key (fo, co, map) acc)
      opams_map raw_repository
  in
  if tdebug then
    OpamConsole.error "RS:LOXA: snd opams_map\n%s"
      (OpamStd.Format.itemize (fun (d,(f,_,map)) ->
           let map_s =
             if OpamFilename.Map.is_empty map then "\n" else
               "\n" ^
               (OpamStd.Format.itemize ~bullet:"  - " OpamFilename.to_string
                  (OpamFilename.Map.keys map))
           in
           OpamFilename.Dir.to_string d ^ "  __  " ^ OpamFilename.to_string f ^ map_s)
          (OpamFilename.Dir.Map.bindings opams_map));
  repo_def, opams_map

let load_repo_from_tar_gz repo_name tar =
  if OpamConsole.disp_status_line () || OpamConsole.verbose () then
    OpamConsole.status_line "Processing: [%s: loading data]"
      (OpamConsole.colorise `blue (OpamRepositoryName.to_string repo_name));
  let repo_root = tar in
  let aux () =
    let repo_def, opams_map =
      load_raw_opams_and_aux_from_tar repo_name tar
    in
    let opams =
      OpamFilename.Dir.Map.fold (fun pkgdir (filename, content, otherfiles) opams ->
          match read_package_opam_tar ~repo_name ~repo_root pkgdir filename content otherfiles with
          | Some (nv, opam) -> OpamPackage.Map.add nv opam opams
          | None -> opams
        ) opams_map OpamPackage.Map.empty
    in
    repo_def, opams
  in
  Fun.protect (fun () -> aux ()) ~finally:OpamConsole.clear_status

let load_opams_from_tar_gz repo_name tar =
  snd (load_repo_from_tar_gz repo_name tar)

let load_opams_from_dir repo_name repo_root =
  if OpamConsole.disp_status_line () || OpamConsole.verbose () then
    OpamConsole.status_line "Processing: [%s: loading data]"
      (OpamConsole.colorise `blue (OpamRepositoryName.to_string repo_name));
  (* FIXME: why is this different from OpamPackage.list ? *)
  let rec aux r dir =
    if OpamFilename.exists_dir dir then
      let fnames = Sys.readdir (OpamFilename.Dir.to_string dir) in
      if Array.exists (fun f -> f = "opam") fnames then
        match read_package_opam_dir ~repo_name ~repo_root dir with
        | Some (nv, opam) -> OpamPackage.Map.add nv opam r
        | None -> r
      else
        Array.fold_left (fun r name -> aux r OpamFilename.Op.(dir / name))
          r fnames
    else r
  in
  Fun.protect
    (fun () -> aux OpamPackage.Map.empty (OpamRepositoryPath.packages_dir repo_root))
    ~finally:OpamConsole.clear_status

let load_opams repo_name repo_root =
  match repo_root with
  | OpamRepositoryRoot.Dir dir ->
    load_opams_from_dir repo_name dir
  | OpamRepositoryRoot.Tar tar ->
    load_opams_from_tar_gz repo_name tar

let load_opams_from_diff repo diffs rt =
  let tdebug = false in
  if OpamConsole.disp_status_line () || OpamConsole.verbose () then
    OpamConsole.status_line "Processing: [%s: loading data]"
      (OpamConsole.colorise `blue (OpamRepositoryName.to_string repo.repo_name));
  let existing_opams =
    OpamRepositoryName.Map.find repo.repo_name rt.repo_opams
  in
  let process_file =
    match get_repo_root rt repo with
    | OpamRepositoryRoot.Tar tar ->
      let repo_root = tar in
      if tdebug then
        OpamConsole.error "RS:load opams from diff: tar mode";
      let _, opams_map =
        load_raw_opams_and_aux_from_tar repo.repo_name tar
      in
      let read pkg_dir =
      let open OpamStd.Option.Op in
        OpamFilename.Dir.Map.find_opt pkg_dir opams_map
        >>=  fun (filename, content, xfiles) ->
        read_package_opam_tar ~repo_name:repo.repo_name
          ~repo_root pkg_dir filename content xfiles
      in
      if tdebug then
        OpamConsole.error "RS:load opams from diff: patch ops\n%s"
          (OpamStd.Format.itemize
             (Format.asprintf "%a" Patch.pp_operation)
             diffs);
      fun (opams, processed_dirs) file ~is_removal ->
        let pkg_dir =
          let file = OpamFilename.raw file in
          let dirname = OpamFilename.dirname file in
          let basename = OpamFilename.basename_dir dirname in
          let full_path =
            (OpamFilename.Dir.to_string dirname)
          in
          if OpamFilename.Base.to_string basename = "files" then
            OpamFilename.raw_dir (Filename.dirname full_path)
          else
            OpamFilename.raw_dir full_path
        in
        if OpamFilename.Dir.Set.mem pkg_dir processed_dirs then
          opams, processed_dirs
        else
          let processed_dirs = OpamFilename.Dir.Set.add pkg_dir processed_dirs in
          (match read pkg_dir with
           | Some (nv, opam) ->
             OpamPackage.Map.add nv opam opams, processed_dirs
           | None ->
             if is_removal then
               match OpamPackage.of_dirname pkg_dir with
               | None ->
                 log "ERR: directory name not a valid package: ignored %s"
                   (OpamFilename.Dir.to_string pkg_dir);
                 opams, processed_dirs
               | Some nv ->
                 OpamPackage.Map.remove nv opams, processed_dirs
             else
               opams, processed_dirs
          )
    | OpamRepositoryRoot.Dir repo_root ->
      if tdebug then
        OpamConsole.error "RS:load opams from diff: dir mode";
      (if tdebug then
         let dir = OpamRepositoryRoot.Dir.to_dir repo_root in
         OpamConsole.error "RD:load_ opamsfrom diff: files in %s:\n%s"
           (OpamFilename.Dir.to_string dir)
           (OpamStd.Format.itemize (fun f ->
                Printf.sprintf "%s [%s]"
                  (OpamFilename.to_string f)
                  (try List.hd (String.split_on_char '\n' (OpamFilename.read f))
                   with _ -> "ERROR"))
               (OpamFilename.rec_files dir)));
      fun (opams, processed_dirs) file ~is_removal ->
        let pkg_dir =
          let file = OpamFilename.raw file in
          let dirname = OpamFilename.dirname file in
          let basename = OpamFilename.basename_dir dirname in
          let full_path =
            Filename.concat
              (OpamRepositoryRoot.Dir.to_string repo_root)
              (OpamFilename.Dir.to_string dirname)
          in
          if OpamFilename.Base.to_string basename = "files" then
            OpamFilename.Dir.of_string (Filename.dirname full_path)
          else
            OpamFilename.Dir.of_string full_path
        in
        if OpamFilename.Dir.Set.mem pkg_dir processed_dirs then
          opams, processed_dirs
        else
          let processed_dirs = OpamFilename.Dir.Set.add pkg_dir processed_dirs in
          match read_package_opam_dir ~repo_name:repo.repo_name ~repo_root pkg_dir with
          | Some (nv, opam) -> OpamPackage.Map.add nv opam opams, processed_dirs
          | None ->
            if is_removal then
              match OpamPackage.of_dirname pkg_dir with
              | None ->
                log "ERR: directory name not a valid package: ignored %s"
                  (OpamFilename.Dir.to_string pkg_dir);
                opams, processed_dirs
              | Some nv ->
                OpamPackage.Map.remove nv opams, processed_dirs
            else
              opams, processed_dirs
  in
  let remove_file file acc = process_file acc file ~is_removal:true in
  let add_file file acc = process_file acc file ~is_removal:false in
  let process_operation acc = function
    | Patch.Edit (old_file, new_file) ->
      if String.equal old_file new_file
      then
        add_file new_file acc
      else
        remove_file old_file acc |> add_file new_file
    | Patch.Delete file -> remove_file file acc
    | Patch.Create file -> add_file file acc
    | Patch.Git_ext (file1, file2, git_ext) ->
      match git_ext with
      | Patch.Rename_only (_, _) -> remove_file file1 acc |> add_file file2
      | Patch.Delete_only -> remove_file file1 acc
      | Patch.Create_only -> add_file file2 acc
  in
  Fun.protect
    (fun () -> List.fold_left process_operation
        (existing_opams, OpamFilename.Dir.Set.empty) diffs |> fst)
    ~finally:OpamConsole.clear_status
(*

  let repo_root = get_repo_root rt repo in
  let open OpamFilename.Op in
  let add, remove =
    let packages_dir =
      OpamRepositoryPath.packages_dir repo_root
      |> OpamFilename.remove_prefix_dir repo_root
      |> OpamFilename.raw_dir
    in
    let is_opam_file file =
      let filename = OpamFilename.raw file in
      if OpamFilename.starts_with packages_dir filename then
        if OpamFilename.Base.equal (OpamFilename.basename filename)
            (OpamFilename.Base.of_string "opam") then
          match OpamPackage.of_filename filename with
          | Some nv -> Some nv
          | None ->
            log "ERR: directory name not a valid package: ignored %s"
              (OpamFilename.to_string (repo_root//file));
            None
        else None
      else None
    in
    let is_install_file file =
      OpamRepositoryPath.install_nv_dir (OpamFilename.raw file)
    in
    let aux file ~rm (adds, rms, xfs)=
      match is_opam_file file with
      | Some nv ->
        if rm then
          adds, nv::rms, xfs
        else
          OpamPackage.Map.add nv file adds, rms, xfs
      | None ->
        match is_install_file file with
        | Some (nv, dir) ->
          adds, rms, OpamPackage.Map.add nv dir xfs
        | None -> adds, rms, xfs
    in
    aux ~rm:false, aux ~rm:true
  in
  let operations acc  = function
    | Patch.Edit (old_file, new_file) ->
      if String.equal old_file new_file then
        add new_file acc
      else
        add new_file acc |> remove old_file
    | Patch.Delete file -> remove file acc
    | Patch.Create file -> add file acc
    | Patch.Git_ext (file1, file2, git_ext) ->
      match git_ext with
      | Patch.Rename_only (_, _) ->
        add file2 acc |> remove file1
      | Patch.Delete_only -> remove file1 acc
      | Patch.Create_only -> add file2 acc
  in
  let additions, removals, xfiles =
    List.fold_left operations OpamPackage.(Map.empty, [], Map.empty) diffs
  in
  let xfiles =
    OpamPackage.Map.fold (fun nv dir lst ->
        if (OpamPackage.Map.mem nv additions) then lst
        else dir::lst)
      xfiles []
  in
  let process_operations opams =
    (* remove obsolete packages *)
    let opams =
      List.fold_left (fun opams nv ->
          OpamPackage.Map.remove nv opams)
        opams removals
    in
    let read_and_add dir opams =
      match read_package_opam ~repo_name:repo.repo_name ~repo_root dir with
      | Some (nv, opam) -> OpamPackage.Map.add nv opam opams
      | None ->
        log "ERR: Could not load %s, ignored"
          (OpamFilename.to_string (dir//"opam"));
        opams
    in
    (* add new packages *)
    let opams =
      OpamPackage.Map.fold (fun _nv file ->
          read_and_add (OpamFilename.dirname (repo_root // file)))
        additions opams
    in
    (* update extra files *)
    let opams =
      List.fold_left (fun opams dir ->
          read_and_add (repo_root / (OpamFilename.Dir.to_string dir)) opams)
        opams xfiles
    in
    opams
  in
  Fun.protect (fun () -> process_operations existing_opams)
    ~finally:OpamConsole.clear_status
*)

let load_repo_from_dir repo repo_root =
  let repo_def =
    (* Have a non repo_root dependant version for this ? *)
    OpamFile.Repo.safe_read (OpamRepositoryPath.repo repo_root)
    |> OpamFile.Repo.with_root_url repo.repo_url
  in
  let opams = load_opams_from_dir repo.repo_name repo_root in
  repo_def, opams

let load_repo repo repo_root =
  let t = OpamConsole.timer () in
  let loaded_repo =
    match repo_root with
    | OpamRepositoryRoot.Tar tar ->
      let repo_def, opams =
        load_repo_from_tar_gz repo.repo_name tar
      in
      let repo_def =
        repo_def
        |> OpamFile.Repo.with_root_url repo.repo_url
      in
      repo_def, opams
    | OpamRepositoryRoot.Dir dir ->
      load_repo_from_dir repo dir
  in
  log "loaded opam files from repo %s in %.3fs"
    (OpamRepositoryName.to_string repo.repo_name)
    (t ());
  loaded_repo

let load lock_kind gt =
  log "LOAD-REPOSITORY-STATE %@ %a" (slog OpamFilename.Dir.to_string) gt.root;
  let lock = OpamFilename.flock lock_kind (OpamPath.repos_lock gt.root) in
  let repos_map =
    match OpamFormatUpgrade.as_necessary_repo lock_kind gt with
    | Some repos_map -> repos_map
    | None -> OpamStateConfig.Repos.safe_read ~lock_kind gt
  in
  if OpamStateConfig.is_newer_than_self ~lock_kind gt then
    log "root version (%s) is greater than running binary's (%s); \
         load with best-effort (read-only)"
      (OpamVersion.to_string (OpamFile.Config.opam_root_version gt.config))
      (OpamVersion.to_string (OpamFile.Config.root_version));
  let mk_repo name (url, ta) = {
    repo_name = name;
    repo_url = url;
    repo_trust = ta;
  } in
  let repositories = OpamRepositoryName.Map.mapi mk_repo repos_map in
  let make_rt repos_definitions opams =
    let rt = {
      repos_global = (gt :> unlocked global_state);
      repos_lock = lock;
      repositories;
      repos_definitions;
      repo_opams = opams;
    } in
    rt
  in
  match Cache.load gt.root with
  | Some (repofiles, opams) ->
    log "Cache found";
    make_rt repofiles opams
  | None ->
    log "No cache found";
    OpamFilename.with_flock_upgrade `Lock_read lock @@ fun _ ->
    let repofiles, opams =
      OpamRepositoryName.Map.fold (fun name url (defs, opams) ->
          let repo = mk_repo name url in
          let repo_def, repo_opams =
            load_repo repo (get_root_raw gt.root name)
          in
          OpamRepositoryName.Map.add name repo_def defs,
          OpamRepositoryName.Map.add name repo_opams opams)
        repos_map (OpamRepositoryName.Map.empty, OpamRepositoryName.Map.empty)
    in
    let rt = make_rt repofiles opams in
    Cache.save_new rt;
    rt

let find_package_opt rt repo_list nv =
  List.fold_left (function
      | None ->
        fun repo_name ->
          OpamStd.Option.Op.(
            OpamRepositoryName.Map.find_opt repo_name rt.repo_opams >>=
            OpamPackage.Map.find_opt nv >>| fun opam ->
            repo_name, opam
          )
      | some -> fun _ -> some)
    None repo_list

let build_index rt repo_list =
  List.fold_left (fun acc repo_name ->
      try
        let repo_opams = OpamRepositoryName.Map.find repo_name rt.repo_opams in
        OpamPackage.Map.union (fun a _ -> a) acc repo_opams
      with Not_found ->
        (* A repo is unavailable, error should have been already reported *)
        acc)
    OpamPackage.Map.empty
    repo_list

let get_repo rt name = OpamRepositoryName.Map.find name rt.repositories

let unlock rt =
  OpamSystem.funlock rt.repos_lock;
  (rt :> unlocked repos_state)

let drop rt =
  let _ = unlock rt in ()

let with_write_lock ?dontblock rt f =
  if OpamStateConfig.is_newer_than_self ~lock_kind:`Lock_write rt.repos_global
  then
    OpamConsole.error_and_exit `Locked
      "The opam root has been upgraded by a newer version of opam-state \
       and cannot be written to";
  let ret, rt =
    OpamFilename.with_flock_upgrade `Lock_write ?dontblock rt.repos_lock
    @@ fun _ -> f ({ rt with repos_lock = rt.repos_lock } : rw repos_state)
    (* We don't actually change the field value, but this makes restricting the
       phantom lock type possible *)
  in
  ret, { rt with repos_lock = rt.repos_lock }

let with_ lock gt f =
  let rt = load lock gt in
  OpamStd.Exn.finally (fun () -> drop rt) (fun () -> f rt)

let write_config rt =
  OpamFile.Repos_config.write (OpamPath.repos_config rt.repos_global.root)
    (OpamRepositoryName.Map.filter_map (fun _ r ->
         if r.repo_url = OpamUrl.empty then None
         else Some (r.repo_url, r.repo_trust))
        rt.repositories)

let check_last_update () =
  if OpamCoreConfig.(!r.debug_level) < 0 then () else
  let last_update =
    OpamFilename.written_since
      (OpamPath.state_cache (OpamStateConfig.(!r.root_dir)))
  in
  if last_update > float_of_int (3600*24*21) then
    OpamConsole.note "It seems you have not updated your repositories \
                      for a while. Consider updating them with:\n%s\n"
      (OpamConsole.colorise `bold "opam update");
