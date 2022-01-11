type t = {
  swh_sch_version: int;
  swh_object_type: [`rev | `rel];
  swh_hash: string
}

let is_hex_str len s =
  String.length s = len &&
  try
    String.iter (function
        | '0'..'9' | 'A'..'F' | 'a'..'f' -> ()
        | _ -> raise Exit)
      s;
    true
  with Exit -> false


let of_string s =
(*
    if String.length s = 50 then 
      invalid_arg "OpamSWHID.of_string";
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
       invalid_arg "OpamSWHID.of_string")
  | _ ->
    invalid_arg "OpamSWHID.of_string"


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
      invalid_arg "OpamSWHID.of_string"
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
