(**************************************************************************)
(*                                                                        *)
(*    Copyright 2026 OCamlPro                                             *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

module type PATCH_CONF = sig
  type root
  type file
  type target
  val label : string
  val translate_patch : bool
  val root_to_string : root -> string
  val file_to_string : file -> string
  val end_slash : root -> root
  val get_path : (unit -> unit) -> root -> string -> file
  val ext : file -> string -> file
  val write : file -> string -> target -> target
  val exists : file -> target -> bool
  val exists_dir : file -> target -> bool
  val read : file -> target -> string
  val remove : file -> target -> target
  val remove_dir : file -> target -> target
  val same_dirname : src:file -> dst:file -> bool
  val mv : src:file -> dst:file -> target -> target
  val open_ : root -> (target -> unit) -> unit
  val save : target -> unit
end

(** TAR TODOC : update doc
    [patch ~allow_unclean ?patch_filename ~dir diffs] applies a patch to
    directory [dir].

    @param allow_unclean decides if applying a patch on a directory which
    differs slightly from the one described in the patch file is allowed.
    Allowing unclean applications imitates the default behaviour of GNU Patch. *)
val patch:
  (module PATCH_CONF with type root = 'a) ->
  allow_unclean:bool ->
  [`Patch_file of string | `Patch_diffs of Patch.t list ] -> 'a
  -> (Patch.operation list, exn) result

(** [translate_patch ~dir input_patch output_patch] writes a copy of
    [input_patch] to [output_patch] as though [input_patch] had been applied in
    [dir]. The patch is rewritten such that if text files have different line
    endings then the patch is transformed to patch using the encoding on disk.
    In particular, this means that patches generated against Unix checkouts of
    Git sources will correctly apply to Windows checkouts of the same sources.
*)
val translate_patch: dir:string -> string -> string -> unit

(** [parse_patch ~dir patch_file] processes and parses a patch file.
    Returns the parsed patch diffs or raises [Not_found] if the patch file
    doesn't exist or can't be parsed.
    TAR TODOC update doc for translate*)
val parse_patch: translate:string option -> string -> Patch.t list
