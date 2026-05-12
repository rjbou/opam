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

(** Defines the file hierarchy in repositories *)

open OpamTypes

(* {2} Repository paths *)

(** Module type of internal representation of repositories
    in <opamroot>/repo. Use module {Path(OP)} to  te a {PATH} module.
*)
module type PATH = sig

  (* The type of a repository root, see repository/OpamRepositoryRoot for the
     several types *)
  type repo_root

  (* The type of the returned dirname *)
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
  val opam:
    repo_root -> string option -> package -> OpamFile.OPAM.t OpamFile.t

  (** files {i $repo/packages/XXX/$NAME.$VERSION/files} *)
  val files: repo_root -> string option -> package -> repo_dirname

  (** Return the description file for a given package:
      {i $repo/packages/XXX/$NAME.VERSION/descr} *)
  val descr:
    repo_root -> string option -> package -> OpamFile.Descr_legacy.t OpamFile.t

  (** urls {i $repo/package/XXX/$NAME.$VERSION/url} *)
  val url:
    repo_root -> string option -> package -> OpamFile.URL_legacy.t OpamFile.t

end

module type OP = sig
  type file
  type dir

  (* Concatenate directories dir/dir*)
  val (/): dir -> string -> dir

  (* Concatenate a file dir/file *)
  val (//): dir -> string -> file

  val dir_of_string : string -> dir
end


(** This module is a path construct helper, to be instanciated by an {OP} to
    access basic functions of repository subpaths construction *)
module Path: functor (Op : OP) -> sig

  (** Packages folder: {i packages} *)
  val packages : string option -> OpamPackage.t -> Op.dir

  (** Return the OPAM file for a given package:
      {i packages/XXX/$NAME.$VERSION/opam} *)
  val opam : string option -> OpamPackage.t -> Op.file

  (** files {i packages/XXX/$NAME.$VERSION/files} *)
  val files : string option -> OpamPackage.t -> Op.dir

  (** Return the description file for a given package:
      {i packages/XXX/$NAME.VERSION/descr} *)
  val descr : string option -> OpamPackage.t -> Op.file

  (** urls {i package/XXX/$NAME.$VERSION/url} *)
  val url : string option -> OpamPackage.t -> Op.file

end

(* {2} Other paths *)

val tar: dirname -> repository_name -> filename

(** Prefix where to store the downloaded files cache: {i $opam/download-cache}.
    Warning, this is relative to the opam root, not a repository root. *)
val download_cache: dirname -> dirname

(** Pin global cache, located in temporary directory, cleaned at end of process *)
val pin_cache_dir: unit -> dirname

(** Pin cache for a given download url. *)
val pin_cache: OpamUrl.t -> dirname

(* {2} URL paths *)

(** Url constructor for parts of remote repositories, when applicable (http and
    rsync). Function take the repo's root url. *)
module Remote: sig
  (** Remote repo file *)
  val repo: url -> url

  (** Remote package files: {i $remote/packages} *)
  val packages_url: url -> url

  (** Remote archive {i $remote/archives/$NAME.$VERSION.tar.gz} *)
  val archive: url -> package -> url
end
