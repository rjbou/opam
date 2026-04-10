(**************************************************************************)
(*                                                                        *)
(*    Copyright 2025 Kate Deplaix                                         *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

let tdebug go =
  if go then
    fun fmt ->
      Printf.ksprintf (fun str ->  OpamConsole.error "REPROOT:%s" str) fmt
  else
    fun fmt ->
      Printf.ksprintf (fun _ -> ()) fmt

module Dir = struct
  type t = OpamFilename.Dir.t

  let of_dir = Fun.id
  let to_dir = Fun.id
  let to_string = OpamFilename.Dir.to_string

  let quarantine repo_root = OpamFilename.raw_dir (to_string repo_root ^ ".new")
  let with_tmp = OpamFilename.with_tmp_dir
  let backup ~inn repo_root =
    let open OpamFilename.Op in
    inn / OpamFilename.Base.to_string (OpamFilename.basename_dir repo_root)

  let cwd = OpamFilename.cwd
  let in_dir = OpamFilename.in_dir
  let exists = OpamFilename.exists_dir
  let remove = OpamFilename.rmdir
  let move = OpamFilename.move_dir
  let copy = OpamFilename.copy_dir
  let copy_except_vcs = OpamFilename.copy_dir_except_vcs
  let is_symlink = OpamFilename.is_symlink_dir
  let patch = OpamFilename.patch
  let make_empty = OpamFilename.mkdir
  let dirs = OpamFilename.dirs
  let is_empty = OpamFilename.dir_is_empty
  let dirname = OpamFilename.dirname_dir

  let repo repo_root = OpamFilename.Op.(repo_root // "repo" |> OpamFile.make)

  module Op = struct
    let (/) d s = OpamFilename.Op.(d / s)
    let (//) d s = OpamFilename.Op.(d // s)
  end

end

module Tar = struct
  type t = OpamFilename.t

  let of_file = Fun.id
  let to_file = Fun.id
  let to_string = OpamFilename.to_string

  let quarantine tar = OpamFilename.raw (to_string tar ^ ".new")
  let backup ~inn tar =
    OpamFilename.create inn (OpamFilename.basename tar)

  let exists = OpamFilename.exists
  let remove = OpamFilename.remove
  let extract_in = OpamFilename.extract_in
  let download_as = OpamDownload.download_as
  let copy = OpamFilename.copy
  let move = OpamFilename.move
  let is_symlink = OpamFilename.is_symlink

  let archives : (OpamHash.t, string OpamStd.String.Map.t) Hashtbl.t = Hashtbl.create 8
  let unload_repo_tars () = Hashtbl.clear archives

  let fold f x tar =
  (* TAR TODO : do we need to have a sha256 ? md5 have collision, will it
     really happen irl ? *)
    let hash = OpamHash.compute ~kind:`SHA256 (OpamFilename.to_string tar) in
    match Hashtbl.find_opt archives hash with
    | Some contents ->
      OpamStd.String.Map.fold (fun filename content acc ->
          f acc filename content)
        contents x
    | None ->
      let result, map =
        OpamTar.fold_reg_files (fun (acc, map) file content ->
            f acc file content,
            OpamStd.String.Map.add file content map)
          (x, OpamStd.String.Map.empty) tar
      in
      Hashtbl.add archives hash map;
      result

  let files t =
    fold (fun files file _ -> file::files) [] t
  let ls t =
    OpamStd.Format.itemize Fun.id (files t)

  let _patch_with_dir_extraction ~allow_unclean patch tar =
    (* TAR TODO update when we have tar patch *)
    let job =
      let tdebug = false in
      let open OpamProcess.Job.Op in
      OpamFilename.with_tmp_dir_job @@ fun dir ->
      (* TAR TODO there is in several places an issue wit the
         tarring/untarrings place, there eis a root to add or remove *)
      if tdebug then
        OpamConsole.error "RRT:PATCH: bef TAR CONTENT %s\n%s"
          (to_string tar) (ls tar);
      extract_in tar dir;
      if tdebug then
        OpamConsole.error "RRT:PATCH: extracted in %s\n%s"
          ((OpamFilename.Dir.to_string dir))
          ((OpamStd.Format.itemize Fun.id
              (OpamSystem.ls (OpamFilename.Dir.to_string dir))));
      let diffs =
        OpamFilename.patch ~allow_unclean patch dir
      in
      if tdebug then
        OpamConsole.error "RRT:PATCH: after patch %s\n%s"
          ((OpamFilename.Dir.to_string dir))
          ((OpamStd.Format.itemize Fun.id
              (OpamSystem.ls (OpamFilename.Dir.to_string dir))));
      OpamFilename.make_tar_gz_job ~root:true tar dir
      @@+ function
      | None ->
        if tdebug then
          OpamConsole.error "RRT:PATCH: aft TAR CONTENT %s\n%s"
            (to_string tar) (ls tar);
        Done (diffs)
      | Some _exn -> failwith "make job failure"
    in
    OpamProcess.Job.run job

  exception Internal_patch_error of string
  let patch_t ~allow_unclean ?patch_filename tar diffs =
    let tdebug = tdebug false in
    tdebug
     "patch_t: patch %s"
      (Format.asprintf "%a" Patch.pp_list diffs);
    let internal_patch_error fmt =
      Printf.ksprintf (fun str -> raise (Internal_patch_error str)) fmt
    in
    let patch_info_path =
      OpamStd.Option.default ("in archive "^to_string tar)
        patch_filename
    in
    let get_path file = file in
    let module Tar = OpamTar.Inplace in
    let apply diff tar =
      let patch ~file content diff =
        (* NOTE: The None case returned by [Patch.patch] is only returned
           if [diff = Patch.Delete _]. This sub-function is not called in
           this case so we [assert false] instead. *)
        match Patch.patch ~cleanly:true content diff with
        | Some x -> tar, x
        | None -> assert false (* See NOTE above *)
        | exception _ when not allow_unclean ->
          internal_patch_error "Patch %S does not apply cleanly."
            patch_info_path
        | exception _ ->
          match Patch.patch ~cleanly:false content diff with
          | Some x ->
            let tar =
             OpamStd. Option.map_default (fun content ->
                  Tar.add ~fname:(file^".orig") ~content tar)
                 tar content
            in
            tar, x
          | None -> assert false (* See NOTE above *)
          | exception _ ->
            (* TAR TODO : write somewhere else ?
               Option.iter (write (file^".orig")) content;
               write (file^".rej") (Format.asprintf "%a" Patch.pp diff);
            *)
            internal_patch_error "Patch %S does not apply cleanly."
              patch_info_path
      in
      match diff.Patch.operation with
      | Patch.Edit (file1, file2) ->
        let file1 = get_path file1 in
        let file2 = get_path file2 in
        let file1_exists = Tar.exists ~fname:file1 tar in
        (* That seems to be the GNU patch behaviour *)
        let file = if file1_exists then file1 else file2 in
        let content = Tar.read ~fname:file tar in
        let tar, content = patch ~file:file (Some content) diff in
        let tar = Tar.add ~fname:file ~content tar in
        let tar =
          if file1_exists && file1 <> (file2 : string) then
            Tar.remove_dir ~dname:(Filename.dirname file1) tar
          else
            tar
        in
        tar
      | Patch.Delete file | Patch.Git_ext (file, _, Patch.Delete_only) ->
        let file = get_path file in
        let tar = Tar.remove ~fname:file tar in
        let tar = Tar.remove_dir ~dname:(Filename.dirname file) tar in
        tar
      | Patch.Create file | Patch.Git_ext (_, file, Patch.Create_only) ->
        let file = get_path file in
        let tar, content = patch ~file None diff in
        Tar.add ~fname:file ~content tar
      | Patch.Git_ext (_, _, Patch.Rename_only (src, dst)) ->
        let src = get_path src in
        let dst = get_path dst in
        let tar = Tar.mv ~src ~dst tar in
        let dirname_src = Filename.dirname src in
        let tar =
          if dirname_src <> (Filename.dirname dst : string) then
            Tar.remove_dir ~dname:dirname_src tar
          else tar
        in
        tar
    in
    tdebug "patch: old tar\n%s" (ls tar);
    Tar.with_open_out tar (fun newtar ->
        let newtar =
          List.fold_left (fun newtar diff ->
              apply diff newtar)
            newtar diffs
        in
        Tar.write newtar);
    tdebug "patch: new tar\n%s" (ls tar);
    ()

  let patch ~allow_unclean patch_source tar =
    let operations_result diffs =
      Ok (List.map (fun d -> d.Patch.operation) diffs)
    in
    let patch ?patch_filename diffs =
      patch_t ~allow_unclean ?patch_filename tar diffs
    in
    try
      match patch_source with
      | `Patch_diffs diffs ->
        patch diffs;
        operations_result diffs
      | `Patch_file p ->
        let diffs = OpamSystem.parse_patch ~dir:"" ~file:(OpamFilename.to_string p) in
        patch ~patch_filename:(OpamFilename.to_string p) diffs;
        operations_result diffs
    with exn -> Error exn

  let extract_files cond t =
    fold (fun acc file content ->
        if cond file then (file,content)::acc else acc)
      [] t

  let is_empty t =
    if exists t then
      Some (match files t with | [] -> true | _ -> false)
    else None

end

let make_tar_gz_job = OpamFilename.make_tar_gz_job ~root:true
let extract_in_job = OpamFilename.extract_in_job

type t =
  | Dir of Dir.t
  | Tar of Tar.t

let quarantine = function
  | Dir dir -> Dir (Dir.quarantine dir)
  | Tar tar -> Tar (Tar.quarantine tar)

let backup ~inn = function
  | Dir dir -> Dir (Dir.backup ~inn dir)
  | Tar tar -> Tar (Tar.backup ~inn tar)

let remove = function
  | Dir dir -> Dir.remove dir
  | Tar tar -> Tar.remove tar

let is_empty = function
  | Dir dir -> Dir.is_empty dir
  | Tar tar -> Tar.is_empty tar

let make_empty = function
  | Dir dir -> Dir.make_empty dir
  | Tar _tar -> () (* Creating an empty tar file doesn't make sense *)

let dirname = function
  | Dir dir -> OpamFilename.dirname_dir (Dir.to_dir dir)
  | Tar tar -> OpamFilename.dirname (Tar.to_file tar)

let basename = function
  | Dir dir -> OpamFilename.basename_dir (Dir.to_dir dir)
  | Tar tar -> OpamFilename.basename (Tar.to_file tar)

let remove_prefix file = function
  | Dir dir ->
    OpamFilename.remove_prefix dir file
    |> OpamFilename.raw
  | Tar _ -> file

let remove_prefix_dir d = function
  | Dir dir ->
    OpamFilename.remove_prefix_dir dir d
    |> OpamFilename.raw_dir
  | Tar _ -> d

let to_string = function
  | Dir dir -> Dir.to_string dir
  | Tar tar -> Tar.to_string tar


let is_tar = function
  | Dir _ -> false
  | Tar _ -> true

let is_dir = function
  | Dir _ -> true
  | Tar _ -> false

let get_dir = function
  | Dir dir -> dir
  | Tar tar ->
    OpamConsole.error_and_exit `Internal_error
      "OpamRepositoryRoot.dir: Access to non existent repository archive %s"
      (Tar.to_string tar)

let get_tar = function
  | Dir dir ->
    OpamConsole.error_and_exit `Internal_error
      "OpamRepositoryRoot.dir: Access to non existent repository directory %s"
      (Dir.to_string dir)
  | Tar tar -> tar

let ls = function
  | Dir dir ->
    OpamFilename.rec_files dir
    |> OpamStd.Format.itemize OpamFilename.to_string
  | Tar tar -> Tar.ls tar

let wrap_job f =
  match OpamProcess.Job.run (f ()) with
  | Some exn -> raise exn
  | None -> ()

let copy_job ~src ~dst =
  let open OpamProcess.Job.Op in
  match src, dst with
  | Dir src, Dir dst -> Dir.copy ~src ~dst; Done None
  | Tar src, Tar dst -> Tar.copy ~src ~dst; Done None
  | Tar src, Dir dst -> OpamFilename.extract_in_job src dst
  | Dir src, Tar dst -> OpamFilename.make_tar_gz_job dst src

let copy ~src ~dst =
  match src, dst with
  | Dir src, Dir dst -> Dir.copy ~src ~dst
  | Tar src, Tar dst -> Tar.copy ~src ~dst
  | Tar src, Dir dst -> OpamFilename.extract_in src dst
  | Dir src, Tar dst ->
    wrap_job @@ fun () -> OpamFilename.make_tar_gz_job dst src

let move_job ~src ~dst =
  let open OpamProcess.Job.Op in
  match src, dst with
  | Dir src, Dir dst -> Dir.move ~src ~dst; Done None
  | Tar src, Tar dst -> Tar.move ~src ~dst; Done None
  | Tar _, Dir _
  | Dir _, Tar _ ->
    copy_job ~src ~dst @@+ function
    | None -> remove src; Done None
    | Some exn -> Done (Some exn)

let move ~src ~dst =
  match src, dst with
  | Dir src, Dir dst -> Dir.move ~src ~dst
  | Tar src, Tar dst -> Tar.move ~src ~dst
  | Tar _, Dir _
  | Dir _, Tar _ ->
    copy ~src ~dst;
    remove src

let exists = function
  | Dir dir -> Dir.exists dir
  | Tar tar -> Tar.exists tar

let is_symlink = function
  | Dir dir -> Dir.is_symlink dir
  | Tar tar -> Tar.is_symlink tar

let patch ~allow_unclean patch = function
  | Dir dir -> Dir.patch ~allow_unclean patch dir
  | Tar tar -> Tar.patch ~allow_unclean patch tar

let read_file (type a) (module R : OpamFile.IO_FILE with type t = a)
    ?(safe=false) repo_root
  : ?filename:a OpamFile.t -> string -> a =
  let rd =
    if safe then R.safe_read_from_string
    else R.read_from_string
  in
  rd ~loc:(to_string repo_root)

let delayed_read_repo = function
  | Dir dir ->
    let repo_file_path = Dir.repo dir in
    let read () = OpamFile.Repo.safe_read repo_file_path in
    (OpamFile.exists repo_file_path, read)
  | Tar tar ->
    let repo_content =
      let exception Found of string in
      try
        Tar.fold (fun () fname content ->
        (* TAR TODO :  here we need to have the inner repo file bc root of
           archive is the directory of the repo. Maybe it need to be changed,
           it will have an impact in a lot of stuff *)
            if fname = "repo" then
              raise (Found content))
(*
            match String.split_on_char Filename.dir_sep.[0] fname with
            | [_; "repo"] -> raise (Found content)
            | _ -> ())
*)
          () (Tar.to_file tar);
        None
      with Found content -> Some content
    in
    let read () =
      match repo_content with
      | None -> OpamFile.Repo.empty
      | Some content ->
        try OpamFile.Repo.read_from_string content
        with _ -> OpamFile.Repo.empty
    in
    (Option.is_some repo_content, read)

let in_dir f = function
  | Dir dir -> f dir
  | Tar tar ->
    let tdebug = false in
    OpamFilename.with_tmp_dir (fun dir ->
        Tar.extract_in tar dir;
        let repo_dir = Dir.of_dir dir in
        if tdebug then
          (OpamConsole.error "dirs %s"
             (OpamStd.List.to_string OpamFilename.Dir.to_string
                (OpamFilename.dirs dir));
           OpamConsole.error "XXXXXXXX dir is %s"
             (OpamStd.String.split
                ( OpamFilename.Dir.to_string dir) '/'
              |> OpamStd.List.to_string Fun.id));
        let res = f repo_dir in
        let open OpamProcess.Job.Op in
        OpamProcess.Job.run
          (make_tar_gz_job tar repo_dir
           @@| function
           | Some e ->
             Printf.ksprintf failwith
               "Failed to regenerate local repository archive: %s"
               (Printexc.to_string e)
           | None ->
             if tdebug then
               OpamConsole.error "After Archive\n%s"
                 (Tar.ls tar);
             res))
