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

module Names :sig
  val repo : string
  val repo_f : string
  val packages : string
  val download_cache : string
  val files : string
end

(** Prefix where to store the downloaded files cache: {i $opam/download-cache}.
    Warning, this is relative to the opam root, not a repository root. *)
val download_cache: dirname -> dirname

(** Returns package and main directory if the path is an install file one:
    {i $repo/packages/XXX[/...]/$NAME.$VERSION/files/...}
*)
val install_nv_dir: OpamFilename.Raw.t -> (package * OpamFilename.Raw.Dir.t) option

(** Pin global cache, located in temporary directory, cleaned at end of process *)
val pin_cache_dir: unit -> dirname

(** Pin cache for a given download url. *)
val pin_cache: OpamUrl.t -> dirname

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
