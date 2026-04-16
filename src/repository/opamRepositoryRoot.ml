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

module type PATH = sig
  open OpamTypes
  type rooot
  type dirname

  (** Repository local path: {i $opam/repo/<name>} *)
  val root: OpamFilename.Dir.t -> repository_name -> rooot

  (** Return the repo file *)
  val repo: rooot -> OpamFile.Repo.t OpamFile.t

  (** Packages folder: {i $repo/packages} *)
  val packages_dir: rooot -> dirname

  (** Package folder: {i $repo/packages/XXX/$NAME.$VERSION} *)
  val packages: rooot -> string option -> package -> dirname

  (** Return the OPAM file for a given package:
      {i $repo/packages/XXX/$NAME.$VERSION/opam} *)
  val opam: rooot -> string option -> package -> OpamFile.OPAM.t OpamFile.t

  (** Return the description file for a given package:
      {i $repo/packages/XXX/$NAME.VERSION/descr} *)
  val descr: rooot -> string option -> package -> OpamFile.Descr.t OpamFile.t

  (** urls {i $repo/package/XXX/$NAME.$VERSION/url} *)
  val url: rooot -> string option -> package -> OpamFile.URL.t OpamFile.t

  (** files {i $repo/packages/XXX/$NAME.$VERSION/files} *)
  val files: rooot -> string option -> package -> dirname
end

module type OP = sig
  type file
  type dir
  val (/): dir -> string -> dir
  val (//): dir -> string -> file
  val dir_of_string : string -> dir
end

module Path (Op: OP) = struct
  open Op

  let repo = OpamRepositoryPath.Names.repo_f
  let packages_dir = OpamRepositoryPath.Names.packages

  let packages prefix nv =
    match prefix with
    | None   -> (dir_of_string packages_dir) / OpamPackage.to_string nv
    | Some p -> (dir_of_string packages_dir) / p / OpamPackage.to_string nv

  let opam prefix nv = packages prefix nv // "opam"
  let descr prefix nv = packages prefix nv // "descr"
  let url prefix nv = packages prefix nv // "url"
  let files prefix nv = packages prefix nv / OpamRepositoryPath.Names.files

end

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

  module Op = struct
    let (/) d s = OpamFilename.Op.(d / s)
    let (//) d s = OpamFilename.Op.(d // s)
  end

  module Path = struct
    module P = Path (struct
        type file = OpamFilename.t
        type dir = OpamFilename.Dir.t
        include OpamFilename.Op
        let dir_of_string = OpamFilename.raw_dir
      end)
    type rooot = t
    type dirname = OpamFilename.Dir.t
    open OpamFilename.Op
    let raw_d = OpamFilename.Dir.to_string
    let raw = OpamFilename.to_string

    let root root name =
      of_dir (root / OpamRepositoryPath.Names.repo / OpamRepositoryName.to_string name)
    let repo root = OpamFile.make (root // P.repo)
    let packages_dir root = root / P.packages_dir
    let packages root prefix nv = root / (raw_d (P.packages prefix nv))
    let make_file f root prefix nv = OpamFile.make (root // (raw (f prefix nv)))
    let opam = make_file P.opam
    let descr = make_file P.descr
    let url = make_file P.url
    let files root prefix nv = root / raw_d (P.files prefix nv)
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

  let archives : (OpamHash.t, string OpamFilename.Raw.Map.t) Hashtbl.t = Hashtbl.create 8
  let unload_repo_tars () = Hashtbl.clear archives

  let fold f x tar =
    (* TAR TOQUESTION : do we need to have a sha256 ? md5 have collision, will it
       really happen irl ? *)
    let hash = OpamHash.compute ~kind:`SHA256 (OpamFilename.to_string tar) in
    match Hashtbl.find_opt archives hash with
    | Some contents ->
      OpamFilename.Raw.Map.fold (fun filename content acc ->
          f acc filename content)
        contents x
    | None ->
      let result, map =
        OpamTar.fold_reg_files (fun (acc, map) file content ->
            f acc file content,
            OpamFilename.Raw.Map.add file content map)
          (x, OpamFilename.Raw.Map.empty) tar
      in
      Hashtbl.add archives hash map;
      result

  let files t =
    fold (fun files file _ -> file::files) [] t
  let ls t =
    OpamStd.Format.itemize OpamFilename.Raw.to_string (files t)

  let patch ~allow_unclean patch_source tar =
    let patch_source =
      match patch_source with
      | `Patch_file f -> `Patch_file (OpamFilename.to_string f)
      | `Patch_diffs _ as d -> d
    in
    OpamTar.patch ~allow_unclean patch_source tar

  let extract_files cond t =
    fold (fun acc file content ->
        if cond file then (file,content)::acc else acc)
      [] t

  let is_empty t =
    if exists t then
      Some (match files t with | [] -> true | _ -> false)
    else None

  module Path = struct
    module P = Path (struct
        type file = OpamFilename.Raw.t
        type dir = OpamFilename.Raw.Dir.t
        include OpamFilename.Raw.Op
        let dir_of_string = OpamFilename.Raw.Dir.of_string
      end)
    type rooot = t
    type dirname = OpamFilename.Raw.Dir.t
    let root root name =
      let open OpamFilename.Op in
      of_file (root / OpamRepositoryPath.Names.repo
               // (OpamRepositoryName.to_string name ^ ".tar.gz"))
    let (!) = OpamFilename.Raw.of_string
    let (!!) = OpamFilename.Raw.Dir.of_string
    let opamfile_make rf = OpamFile.make (OpamFilename.Raw.to_filename rf)
    let repo _ = opamfile_make (! P.repo)
    let packages_dir _ = !! P.packages_dir
    let packages _ prefix nv = P.packages prefix nv
    let make_file f prefix nv = opamfile_make (f prefix nv)
    let opam _ = make_file P.opam
    let descr _ = make_file P.descr
    let url _ = make_file P.url
    let files (_:rooot) prefix nv = P.files prefix nv
  end

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
    let repo_file_path = Dir.Path.repo dir in
    let read () = OpamFile.Repo.safe_read repo_file_path in
    (OpamFile.exists repo_file_path, read)
  | Tar tar ->
    let repo_content =
      let exception Found of string in
      let repo = OpamFilename.Raw.of_string OpamRepositoryPath.Names.repo_f in
      try
        Tar.fold (fun () fname content ->
            if OpamFilename.Raw.equal fname repo then
              raise (Found content))
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

let remove_both root name =
  remove (Tar (Tar.Path.root root name));
  remove (Dir (Dir.Path.root root name))

let root_exists root name =
  exists (Tar (Tar.Path.root root name))
  || exists (Dir (Dir.Path.root root name))
