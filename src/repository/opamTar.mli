(**************************************************************************)
(*                                                                        *)
(*    Copyright 2025 Kate Deplaix                                         *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

(* TAR TODO : documentation *)
(* TAR TODO : use filename instead of string to navigate in archive *)

(*
module File : sig
  include OpamStd.ABSTRACT

  module Dir : sig
    include OpamStd.ABSTRACT
    val of_dir : OpamFilename.Dir.t -> t
    val to_dir : t -> OpamFilename.Dir.t
  end

  module Base : sig
    include OpamStd.ABSTRACT
    val of_base : OpamFilename.Base.t -> t
    val to_base : t -> OpamFilename.Base.t
  end

  module Op : sig
    (** Create a new directory *)
    val (/): Dir.t -> string -> Dir.t

    (** Create a new filename *)
    val (//): Dir.t -> string -> t
  end

  val of_filename : filename -> t
  val to_filename : t -> filename

  (** Check whether a filename starts by a given Dir.t *)
  val starts_with: Dir.t -> t -> bool

  (** Add a file extension *)
  val add_extension: t -> string -> t

  (** Return the directory name *)
  val dirname: t -> Dir.t

  (** Return the base name *)
  val basename: t -> Base.t

  (** Return the deeper directory name *)
  val basename_dir: Dir.t -> Base.t

  (** Retrieves the contents from the hard disk. *)
  val read: t -> string

  (** Remove a prefix from a file name *)
  val remove_prefix: Dir.t -> t -> string

  (* val remove_prefix_dir: Dir.t -> Dir.t -> string *)
  val root_dir: t -> string option

end
*)

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
