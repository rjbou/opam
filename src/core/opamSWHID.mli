(**************************************************************************)
(*                                                                        *)
(*    Copyright 2021 OCamlPro                                             *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

(* Software Heritage Identifiers *)
type t = {
  swh_sch_version: int;
  swh_object_type: [ `rev | `rel | `dir ];
  swh_hash: string
}

include OpamStd.ABSTRACT with type t := t

(** url things *)

(** Check url validity regarding its form:
    http backend and swhid path prefix [swhid.opam.ocaml.org] *)
val is_valid: OpamUrl.t -> bool

val of_url: OpamUrl.t -> t option
val to_url: t -> OpamUrl.t

val compute: OpamFilename.Dir.t -> string option
