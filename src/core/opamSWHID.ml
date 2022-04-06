(**************************************************************************)
(*                                                                        *)
(*    Copyright 2021 OCamlPro                                             *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

type t = {
  swh_sch_version: int;
  swh_object_type: [ `rev | `rel | `dir ];
  swh_hash: string
}

let compare {swh_sch_version; swh_object_type; swh_hash} swh =
  let scheme_version = swh_sch_version - swh.swh_sch_version in
  if scheme_version <> 0 then scheme_version else
  let object_type = compare swh_object_type swh.swh_object_type in
  if object_type <> 0 then object_type else
    String.compare swh_hash swh.swh_hash

let equal a b = compare a b = 0

let of_string s =
  let invalid () = invalid_arg "OpamSWHID.of_string"  in
  match OpamStd.String.split s ':' with
  | "swh"::sv::("rev"|"rel"|"dir" as ot)::swh_hash::[] ->
    (* Only api version 1 is handled for the moment *)
    let swh_sch_version =
      try
        let scheme = int_of_string sv in
        if scheme <> 1 then invalid () else scheme
      with Failure _ -> invalid ()
    in
    (* format defined in
       https://docs.softwareheritage.org/devel/swh-model/persistent-identifiers.html *)
    if String.length swh_hash <> 40 || not (OpamStd.String.is_hex swh_hash) then
      invalid ();
    let swh_object_type =
      (* on rev & rel support: https://forge.softwareheritage.org/T1258i *)
      match ot with
      | "rev" -> `rev
      | "rel" -> `rel
      | "dir" -> `dir
      | _ -> invalid ()
    in
    { swh_sch_version; swh_object_type; swh_hash }
  | _ -> invalid ()

let to_string s =
  Printf.sprintf "swh:%d:%s:%s"
    s.swh_sch_version
    (match s.swh_object_type with
     | `rev -> "rev" | `rel -> "rel" | `dir -> "dir")
    s.swh_hash

let of_string_opt s =
  try Some (of_string s) with Invalid_argument _ -> None

let to_json s = `String (to_string s)
let of_json = function
  | `String s -> of_string_opt s
  | _ -> None

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
let digest_string_to_hex = OpamSHA.sha256
end
module OS = struct

open OpamFilename

let contents directory =
  let dir = OpamFilename.Dir.of_string directory in
  Some ((files dir |> List.map to_string)
        @ (dirs dir |> List.map Dir.to_string))

let typ name =  None
let read_file name =
  try
    Some OpamFilename.(read (of_string name))
  with
    _ -> None
let permissions name = None
let base name = OpamFilename.(Base.to_string (basename (of_string name)))

end
module Compute = Swhid_compute.Make(SHA1)(OS)

let check archive =

