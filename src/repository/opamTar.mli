(**************************************************************************)
(*                                                                        *)
(*    Copyright 2025 Kate Deplaix                                         *)
(*    Copyright 2025 OCamlPro                                             *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

(** Tar gz archives manipulation *)

open OpamTypes

type tar = filename
type tar_file = unix_filename
type tar_content = string

(* Fold over the content of an archive *)
val fold_reg_files :
  ('acc -> tar_file -> tar_content -> 'acc) -> 'acc -> tar -> 'acc

(* [create_flat tar dir] Creates an compressed archive [tar] containing the flat
   content of [dir] *)
val create_flat : tar -> dirname -> unit

(* Apply a patch on an archive *)
val patch:
  allow_unclean:bool ->
  [`Patch_file of string | `Patch_diffs of Patch.t list ] -> tar ->
  (Patch.operation list, exn) result

(* This module contains helpers to act on the archive once openned *)
module Inplace : sig
  type t

  (* Open an archive and fold over it *)
  val with_open_out : tar -> (t -> 'a) -> 'a

  (* Fold over the content of an archive *)
  val fold_reg_files :
    ('acc -> tar_file -> tar_content -> 'acc) ->
    'acc -> t -> 'acc

  (* Return the content of the filename from the archive *)
  val read: tar_file -> t -> tar_content

  (* Add a file in an archive *)
  val add : tar_file -> tar_content -> t -> t

  (* Remove a file from an archive *)
  val remove : tar_file -> t -> t

  (* Remove the content of a directory from an archive *)
  val remove_dir : unix_dirname -> t -> t

  (* Move a file in the archive *)
  val mv: src:tar_file -> dst:tar_file -> t -> t

  (* Return true if the filename exists in the archive *)
  val exists: tar_file -> t -> bool

  (* Write the archive on disk *)
  val write : t -> unit
end
