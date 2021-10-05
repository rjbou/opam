(**************************************************************************)
(*                                                                        *)
(*    Copyright 2021 OCamlPro                                             *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

open Swhid_types
type t = identifier_core

let compare (sch_version, object_type, hash) (sch_version', object_type', hash') =
  let scheme_version = sch_version - sch_version' in
  if scheme_version <> 0 then scheme_version else
  let object_type = compare object_type object_type' in
  if object_type <> 0 then object_type else
    String.compare hash hash'

let equal a b = compare a b = 0

let of_string s =
  let invalid () = invalid_arg "OpamSWHID.of_string"  in
  match OpamStd.String.split s ':' with
  | "swh"::sv::"dir"::hash::[] ->
    (* Only api version 1 is handled for the moment *)
    let scheme =
      try
        let scheme = int_of_string sv in
        if scheme <> 1 then invalid () else scheme
      with Failure _ -> invalid ()
    in
    (* format defined in
       https://docs.softwareheritage.org/devel/swh-model/persistent-identifiers.html *)
    if String.length hash <> 40 || not (OpamStd.String.is_hex hash) then
      invalid ();
    (scheme, Directory, hash)
  | _ -> invalid ()

let to_string (sch, ot, h) =
  Printf.sprintf "swh:%d:%s:%s"
    sch
    (match ot with | Directory -> "dir" | _ -> assert false)
    h

let of_string_opt s =
  try Some (of_string s) with Invalid_argument _ -> None

let to_json s = `String (to_string s)
let of_json = function
  | `String s -> of_string_opt s
  | _ -> None

let hash (_,_,h) = h

module O = struct
  type _t = t
  type t = _t
  let to_string = to_string
  let to_json = to_json
  let of_json = of_json
  let compare = compare
end

module Set = OpamStd.Set.Make(O)
module Map = OpamStd.Map.Make(O)


(** Url handling *)

let prefix = "swhid.opam.ocaml.org/"

let is_valid url =
  let open OpamUrl in
  url.backend = `http
  && (String.equal url.transport "http" || String.equal url.transport "https")
  && OpamStd.String.starts_with ~prefix url.path

let of_url url =
  try
    Some (of_string (OpamStd.String.remove_prefix ~prefix url.OpamUrl.path))
  with Invalid_argument _ -> None

let to_url swh =
  let path = Printf.sprintf "%s%s" prefix (to_string swh) in
  OpamUrl.{ transport = "https"; backend = `http ; hash = None; path }


module SHA1 = struct
  let digest_string_to_hex = OpamSHA.sha1_string
end
module OS = struct

  let contents dir =
    try Some (OpamSystem.ls dir)
    with _ -> None

  let typ name =
    try if Sys.is_directory name then Some "dir" else Some "file"
    with _ -> None

  let read_file name =
    try Some (OpamSystem.read name)
    with OpamSystem.File_not_found _ -> None

    (*
      - [0o120000] if [f] is a symlink
      - [0o040000] if [f] is a directory
      - [0o100755] if [f] is an executable file
      - [0o100644] if [f] is a regular file *)
  let permissions name =
    if not (Sys.file_exists name) then raise Not_found else
    let Unix.{ st_kind; _ } = Unix.lstat name in
    match st_kind with
    | Unix.S_DIR -> Some 0o040000
    | Unix.S_LNK -> Some 0o120000
    | Unix.S_REG ->
      Some (
        if OpamSystem.is_executable name then 0o100755 else 0o100644
      )
    | _ -> None

  let base name = OpamFilename.(Base.to_string (basename (of_string name)))

end

module Compute = Swhid_compute.Make(SHA1)(OS)

let compute dir =
  match Compute.directory_identifier_deep (OpamFilename.Dir.to_string dir) with
  | None ->  None
  | Some identifier ->
    Some (Swhid_types.get_object_id identifier)
