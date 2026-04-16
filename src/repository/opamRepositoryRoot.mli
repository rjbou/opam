(**************************************************************************)
(*                                                                        *)
(*    Copyright 2025 Kate Deplaix                                         *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

(** This module abstract the notion of repository root over its concrete
    implementation (could be a database, a file, a directory, etc.) *)

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

(** Repository root implemented as a directory *)
module Dir : sig
  type t

  val of_dir : OpamFilename.Dir.t -> t
  val to_dir : t -> OpamFilename.Dir.t
  val to_string : t -> string

  (** [quarantine dir] returns a path to a temporary directory dedicated to the
      original repository root. The returned directory is not created and
      points to a statically known directory in the same parent directory
      as [dir]. *)
  val quarantine : t -> t

  val with_tmp : (t -> 'a) -> 'a
  val backup : inn:OpamFilename.Dir.t -> t -> t

  val cwd : unit -> t
  val in_dir : t -> (unit -> 'a) -> 'a
  val exists : t -> bool
  val remove : t -> unit
  val move : src:t -> dst:t -> unit
  val copy : src:t -> dst:t -> unit
  val copy_except_vcs : src:t -> dst:t -> unit
  val make_empty : t -> unit
  val dirs : t -> OpamFilename.Dir.t list
  val is_empty : t -> bool option
  val dirname : t -> OpamFilename.Dir.t

  module Op: sig
    val ( / ) : t -> string -> OpamFilename.Dir.t
    val ( // ) : t -> string -> OpamFilename.t
  end

  module Path : PATH with type rooot = t and type dirname = OpamFilename.Dir.t
end

module Tar : sig
  type t

  val of_file : OpamFilename.t -> t
  val to_file : t -> OpamFilename.t
  val to_string : t -> string

  val quarantine : t -> t
  val backup : inn:OpamFilename.Dir.t -> t -> t

  val exists : t -> bool
  val remove : t -> unit
  val extract_in : t -> OpamFilename.Dir.t -> unit
  val download_as :
    ?quiet:bool ->
    ?validate:bool ->
    overwrite:bool ->
    ?compress:bool ->
    ?checksum:OpamHash.t ->
    OpamUrl.t -> t -> unit OpamProcess.job
  val copy : src:t -> dst:t -> unit
  val move : src:t -> dst:t -> unit

  (* TAR TODO: for debug purpose *)
  val files : t -> OpamTar.tar_file list
  val ls : t -> string
  val extract_files:
    (OpamTar.tar_file -> bool) -> t -> (OpamTar.tar_file * OpamTar.tar_content) list
  val fold: ('a -> OpamTar.tar_file -> OpamTar.tar_content -> 'a) -> 'a -> t -> 'a
  (* clean hashtbl that keep the repositories in ram *)
  val unload_repo_tars: unit -> unit

  module Path : PATH with type rooot = t and type dirname = OpamFilename.Raw.Dir.t
end

val make_tar_gz_job : Tar.t -> Dir.t -> exn option OpamProcess.job
val extract_in_job : Tar.t -> Dir.t -> exn option OpamProcess.job

type t =
  | Dir of Dir.t
  | Tar of Tar.t

(** [quarantine repo_root] returns a temporary repository root dedicated
    to [repo_root]. the returned repository is not created on disk and
    points to a statically known repository located in the same parent
    directory as [repo_root]. *)
val quarantine : t -> t

(* backup into [inn] *)
val backup: inn:OpamFilename.Dir.t -> t -> t

val remove : t -> unit
val is_empty : t -> bool option
val make_empty : t -> unit
val dirname : t -> OpamFilename.Dir.t
val basename : t -> OpamFilename.Base.t
val remove_prefix: OpamFilename.t -> t -> OpamFilename.t
val remove_prefix_dir: OpamFilename.Dir.t -> t -> OpamFilename.Dir.t
val to_string : t -> string
val read_file:
  (module OpamFile.IO_FILE with type t = 'a) ->
  ?safe:bool -> t -> ?filename:'a OpamFile.t -> OpamTar.tar_content -> 'a

val is_tar: t -> bool
val is_dir: t -> bool
val get_dir: t -> Dir.t
val get_tar: t -> Tar.t
val ls: t -> string

val copy_job : src:t -> dst:t -> exn option OpamProcess.job
val move_job : src:t -> dst:t -> exn option OpamProcess.job
val copy : src:t -> dst:t -> unit
val move : src:t -> dst:t -> unit
val exists : t -> bool
val is_symlink : t -> bool
val patch :
  allow_unclean:bool ->
  [`Patch_file of OpamFilename.t | `Patch_diffs of Patch.t list ] -> t ->
  (Patch.operation list, exn) result

(** Returns a pair [(exists, f)] where [exists] tells whether the
    [repo] file exists in the repository and [f] reads it *)
val delayed_read_repo : t -> bool * (unit -> OpamFile.Repo.t)

(** Applies the function in the repository root directory. If repository root
    is an archive, it uncompress it, applies the function and update archive
    with the changed directory. *)
val in_dir: (OpamFilename.Dir.t -> 'a) -> t -> 'a

(** TAR TODOC remove directory and archive, if present *)
val remove_both : OpamFilename.Dir.t -> OpamRepositoryName.t -> unit
val root_exists : OpamFilename.Dir.t -> OpamRepositoryName.t -> bool
