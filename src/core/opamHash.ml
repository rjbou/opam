(**************************************************************************)
(*                                                                        *)
(*    Copyright 2016-2019 OCamlPro                                        *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

type kind = [ `MD5 | `SHA256 | `SHA512 ]

let default_kind = `MD5

type t = kind * string

let kind = fst
let contents = snd

(* Order by hash strength: MD5 < SHA256 < SHA512 *)
let compare_kind k l =
  match k, l with
  | `SHA512, `SHA512 | `SHA256, `SHA256 | `MD5, `MD5 -> 0
  | `MD5, _ | _, `SHA512 -> -1
  | `SHA512, _ | _, `MD5 -> 1

let compare (k,h) (l,i) =
  match compare_kind k l with
  | 0 -> String.compare h i
  | cmp -> cmp

let equal h h' = compare h h' = 0

let log msg = OpamConsole.log "HASH" msg

let pfx_sep_char = '='
let pfx_sep_str = String.make 1 pfx_sep_char

let string_of_kind = function
  | `MD5 -> "md5"
  | `SHA256 -> "sha256"
  | `SHA512 -> "sha512"

let kind_of_string s = match String.lowercase_ascii s with
  | "md5" -> `MD5
  | "sha256" -> `SHA256
  | "sha512" -> `SHA512
  | _ -> invalid_arg "OpamHash.kind_of_string"

let is_hex_str len s =
  String.length s = len &&
  try
    String.iter (function
        | '0'..'9' | 'A'..'F' | 'a'..'f' -> ()
        | _ -> raise Exit)
      s;
    true
  with Exit -> false

let len = function
  | `MD5 -> 32
  | `SHA256 -> 64
  | `SHA512 -> 128

let valid kind = is_hex_str (len kind)

let make kind s =
  if valid kind s then kind, String.lowercase_ascii s
  else invalid_arg ("OpamHash.make_"^string_of_kind kind)

let md5 = make `MD5
let sha256 = make `SHA256
let sha512 = make `SHA512

let of_string_opt s =
  try
    let kind, s =
      match OpamStd.String.cut_at s pfx_sep_char with
      | None -> `MD5, s
      | Some (skind, s) -> kind_of_string skind, s
    in
    if valid kind s then Some (kind, String.lowercase_ascii s)
    else None
  with Invalid_argument _ -> None

let of_string s =
  match of_string_opt s with
  | Some h -> h
  | None -> invalid_arg "OpamHash.of_string"

let to_string (kind,s) =
  String.concat pfx_sep_str [string_of_kind kind; s]

let to_json s = `String (to_string s)
let of_json = function
| `String s -> of_string_opt s
| _ -> None

let to_path (kind,s) =
  [string_of_kind kind; String.sub s 0 2; s]

let sort checksums =
  List.sort (fun h h' -> compare h' h) checksums

let compute ?(kind=default_kind) file = match kind with
  | `MD5 -> md5 (Digest.to_hex (Digest.file file))
  | (`SHA256 | `SHA512) as kind ->
    let sha =
      if not OpamCoreConfig.(!r.use_openssl) then
        OpamSHA.hash kind file
      else
      try
        match
          OpamSystem.read_command_output ["openssl"; string_of_kind kind; file]
        with
        | [l] ->
          let len = len kind in
          String.sub l (String.length l - len) len
        | _ ->
          log "openssl error, use internal sha library";
          OpamSHA.hash kind file
      with OpamSystem.Command_not_found _ | OpamSystem.Process_error _ | OpamSystem.Permission_denied _ ->
        log "openssl not found, use internal sha library";
        OpamSHA.hash kind file
    in
    make kind sha

let compute_from_string ?(kind=default_kind) str = match kind with
  | `MD5 -> md5 (Digest.to_hex (Digest.string str))
  | (`SHA256 | `SHA512) as kind ->
    make kind (OpamSHA.hash_bytes kind (Bytes.of_string str))

let check_file f (kind, _ as h) = compute ~kind f = h

let mismatch f (kind, _ as h) =
  let hf = compute ~kind f in
  if hf = h then None else Some hf

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

module SWHID = struct
  type t = {
  swh_sch_version: int;
  swh_object_type: [`rev | `rel];
  swh_hash: string
  }
  
  let of_string s =
(*
    if String.length s = 50 then 
      invalid_arg "OpamHash.SWHID.of_string";
*)
    match OpamStd.String.split s ':' with
    | "swh"::sv::("rev"|"rel" as ot)::s::[] ->
      (try
         if int_of_string sv <> 1 then raise Exit;
         if is_hex_str 40 s then raise Exit;
         { swh_sch_version = int_of_string sv;
           swh_object_type =
             (match ot with
              | "rev" -> `rev
              | "rel" -> `rel
              | _ -> raise Exit);
           swh_hash = s }
       with Exit ->
         invalid_arg "OpamHash.SWHID.of_string")
    | _ ->
      invalid_arg "OpamHash.SWHID.of_string"


(*
  let is_valid s =
    String.length s = 50 &&
    (* format from
       https://docs.softwareheritage.org/devel/swh-model/persistent-identifiers.html
       on rev & rel support: https://forge.softwareheritage.org/T1258
    *)
    match OpamStd.String.split s ':' with
    | "swh"::"1"::("rev"|"rel")::s::[] -> is_hex_str 40 s
    | _ -> false

*)
(*
  let to_path s =
    ["swhid"; String.sub s 10 2; String.sub s 10 40]
*)

  let to_string s =
    Printf.sprintf "swh:%d:%s:%s"
      s.swh_sch_version
      (match s.swh_object_type with
       | `rev -> "rev" | `rel -> "rel")
      s.swh_hash

(*
  let of_string s =
    if is_valid s then s else
      invalid_arg "OpamHash.SWHID.of_string"
*)
  let of_string_opt s =
    try Some (of_string s) with Invalid_argument _ -> None
  let to_json s = `String (to_string s)
  let of_json = function
    | `String s -> of_string_opt s
    | _ -> None

  (** XXX specialise! *)
  let compare a b = String.compare a.swh_hash b.swh_hash
  let equal a b = compare a b = 0

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
end

