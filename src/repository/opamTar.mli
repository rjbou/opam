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
open OpamTypes

type tar = filename

val fold_reg_files :
  ('acc -> string -> string -> 'acc) -> 'acc -> tar -> 'acc

module Inplace : sig
  type t

  val with_open_out : tar -> (t -> 'a) -> 'a
  val fold_reg_files :
    ('acc -> string -> string -> 'acc) ->
    'acc -> t -> 'acc
  val add : fname:string -> content:string -> t -> t
  val remove : fname:string -> t -> t
  val remove_dir : dname:string -> t -> t
  val exists: fname:string -> t -> bool
  val read: fname:string -> t -> string
  val mv: src:string -> dst:string -> t -> t
  val write : t -> unit
end
