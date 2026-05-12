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

open OpamFilename.Op

(* Repository Paths*)

module type PATH = sig
  open OpamTypes
  type repo_root
  type repo_dirname

  (** Repository local path: {i $opam/repo/<name>} *)
  val root: dirname -> repository_name -> repo_root

  (** Return the repo file *)
  val repo: repo_root -> OpamFile.Repo.t OpamFile.t

  (** Packages folder: {i $repo/packages} *)
  val packages_dir: repo_root -> repo_dirname

  (** Package folder: {i $repo/packages/XXX/$NAME.$VERSION} *)
  val packages: repo_root -> string option -> package -> repo_dirname

  (** Return the OPAM file for a given package:
      {i $repo/packages/XXX/$NAME.$VERSION/opam} *)
  val opam: repo_root -> string option -> package -> OpamFile.OPAM.t OpamFile.t

  (** files {i $repo/packages/XXX/$NAME.$VERSION/files} *)
  val files: repo_root -> string option -> package -> repo_dirname

  (** Return the description file for a given package:
      {i $repo/packages/XXX/$NAME.VERSION/descr} *)
  val descr: repo_root -> string option -> package -> OpamFile.Descr_legacy.t OpamFile.t

  (** urls {i $repo/package/XXX/$NAME.$VERSION/url} *)
  val url: repo_root -> string option -> package -> OpamFile.URL_legacy.t OpamFile.t
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

  let packages prefix nv =
    let pkg_dir = dir_of_string OpamRepositoryPathName.packages_d in
    match prefix with
    | None   -> pkg_dir / OpamPackage.to_string nv
    | Some p -> pkg_dir / p / OpamPackage.to_string nv

  let opam prefix nv = packages prefix nv // OpamRepositoryPathName.opam_f
  let files prefix nv = packages prefix nv / OpamRepositoryPathName.files_d
  let descr prefix nv = packages prefix nv // "descr"
  let url prefix nv = packages prefix nv // "url"

end

(* Other paths *)

let tar root name =
  root / OpamRepositoryPathName.repo_d //
  (OpamRepositoryName.to_string name ^ ".tar.gz")

let download_cache root = root / OpamRepositoryPathName.download_cache_d

let pin_cache_dir =
  let dir =
    lazy (OpamSystem.mk_temp_dir ~prefix:"opam-pin-cache" ()
          |> OpamFilename.Dir.of_string )
  in
  fun () -> Lazy.force dir

let pin_cache u =
  pin_cache_dir () /
  String.sub
    (OpamHash.contents @@
     OpamHash.compute_from_string ~kind:`SHA512 @@
     OpamUrl.to_string u)
    0 16

(* URL paths *)

module Remote = struct
  (** URL, not FS paths *)
  open OpamUrl.Op

  let repo root_url =
    root_url / OpamRepositoryPathName.repo_f

  let packages_url root_url =
    root_url / OpamRepositoryPathName.packages_d

  let archive root_url nv =
    root_url / "archives" / (OpamPackage.to_string nv ^ "+opam.tar.gz")
end
