(**************************************************************************)
(*                                                                        *)
(*    Copyright 2025 Kate Deplaix                                         *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

(* TAR TODOC : documentation *)
(* TAR TODO : use filename instead of string to navigate in archive *)

type tar = OpamFilename.t
type tar_file = OpamFilename.Raw.t
type tar_content = string

val fold_reg_files :
  ('acc -> tar_file -> tar_content -> 'acc) -> 'acc -> tar -> 'acc

val patch:
  allow_unclean:bool ->
  [`Patch_file of string | `Patch_diffs of Patch.t list ] -> tar ->
  (Patch.operation list, exn) result

module Inplace : sig
  type t

  val with_open_out : tar -> (t -> 'a) -> 'a
  val fold_reg_files :
    ('acc -> tar_file -> tar_content -> 'acc) ->
    'acc -> t -> 'acc
  val add : fname:tar_file -> content:tar_content -> t -> t
  val remove : fname:tar_file -> t -> t
  val remove_dir : dname:OpamFilename.Raw.Dir.t -> t -> t
  val exists: fname:tar_file -> t -> bool
  val read: fname:tar_file -> t -> tar_content
  val mv: src:tar_file -> dst:tar_file -> t -> t
  val write : t -> unit
end
