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
  swh_object_type: [`rev | `rel];
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
  match OpamStd.String.split s ':' with
  | "swh"::sv::("rev"|"rel" as ot)::s::[] ->
    (try
       if int_of_string sv <> 1 then raise Exit;
       if String.length s = 40 && OpamStd.String.is_hex s then raise Exit;
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

let to_string s =
  Printf.sprintf "swh:%d:%s:%s"
    s.swh_sch_version
    (match s.swh_object_type with
     | `rev -> "rev" | `rel -> "rel")
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


(** SWHID retrieval functions *)

open OpamProcess.Job.Op

let instance = "https://archive.softwareheritage.org"
let full_url endpoint = Printf.sprintf "%s/api/1%s" instance endpoint

let json_of_string _s = assert false

let find_string _key _v =

  (*
   * $ curl https://archive.softwareheritage.org/api/1/vault/directory/4453cfbdab1a996658cd1a815711664ee7742380/
   * {"fetch_url":"https://archive.softwareheritage.org/api/1/vault/flat/swh:1:dir:4453cfbdab1a996658cd1a815711664ee7742380/raw/","progress_message":null,"id":398307347,"status":"done","swhid":"swh:1:dir:4453cfbdab1a996658cd1a815711664ee7742380","obj_type":"directory","obj_id":"4453cfbdab1a996658cd1a815711664ee7742380"}
   * récupérer status et fetch_url
   *
   * $ curl https://archive.softwareheritage.org/api/1/revision/69c0db5050f623e8895b72dfe970392b1f9a0e2e/
   * {"message":"Update docs and patchlevel for 3.6.1 final\n","author":{"fullname":"Ned Deily <nad@python.org>","name":"Ned Deily","email":"nad@python.org"},"committer":{"fullname":"Ned Deily <nad@python.org>","name":"Ned Deily","email":"nad@python.org"},"date":"2017-03-21T02:32:38-04:00","committer_date":"2017-03-21T02:32:38-04:00","type":"git","directory":"4453cfbdab1a996658cd1a815711664ee7742380","synthetic":false,"metadata":{},"parents":[{"id":"8c18fbeed1c7721b67f1726a6e9c41acef823135","url":"https://archive.softwareheritage.org/api/1/revision/8c18fbeed1c7721b67f1726a6e9c41acef823135/"}],"id":"69c0db5050f623e8895b72dfe970392b1f9a0e2e","extra_headers":[],"merge":false,"url":"https://archive.softwareheritage.org/api/1/revision/69c0db5050f623e8895b72dfe970392b1f9a0e2e/","history_url":"https://archive.softwareheritage.org/api/1/revision/69c0db5050f623e8895b72dfe970392b1f9a0e2e/log/","directory_url":"https://archive.softwareheritage.org/api/1/directory/4453cfbdab1a996658cd1a815711664ee7742380/"}
   * récupérer directory
   *
   * $ curl https://archive.softwareheritage.org/api/1/release/208f61cc7a5dbc9879ae6e5c2f95891e270f09ef/
   * {"name":"v3.6.1","message":"Tag v3.6.1\n-----BEGIN PGP SIGNATURE-----\n\niQIcBAABCgAGBQJY0MxgAAoJEC00fqaqZUIdkZ0QAJw9PR++cbpS3Pt8QrmgS+xG\nPxrZ1yPPNPNSfbmRLWOlHJ0nBzFPVXUWdrqnevmZVRghyrc78sjuBL8QczYsum22\n1B6X/63vX3dI9yj8FR5nldEYPBMOOD6ryObWoKMeqyQT3LhAqxIU/9oqAsbx+ZYw\nrXmRTuypenmZabq3yIv2hORMFgcS7JZFuVb181b0Cihji/7l+WRI9hkGO8POBeFq\ntfJ16beH8hbbDw/+MLpwJifsALWsQOqnWt2/C8tJeHtMX+FLuJflwcIwotv73E22\nulmpXNwTNxnK5l5/C9JC6kr5nN9VJatVpSpe6dftAmTy16O5OrADtePZYxOZ7S3X\n6ipOaiKl3s/2oykkmasxPeaVXllbWgd2UGqIBlAUxM6rVD/4DyVDUHqbDotQD8Kz\nZ8nSFxou1ZdRTSlC26ToGCNc+B6bqv9GTC1hph/ijJkhvXfIC9X1fc/uO1wrV+wB\ni2dxXKh1mQCXuogNAx6rv7gPaXbPgDHob7Tlvo5Ddhr7rQoAaMjceGfUMOTORSqO\nR4ssE6yyNASQtMjW+Y5WeVEgtX7ttGKBsgD0PsrZTCjnZfJkFtZGUyfkdwNzLK8v\nRBqi1r+tEuR5tpin4h+erdlVjeMhVMQZOhBYmxY2Ge70PMVrOz4KaFY1GD+aaxt7\n+PfOKUxMYGKvogv7gD/3\n=Peec\n-----END PGP SIGNATURE-----\n","target":"69c0db5050f623e8895b72dfe970392b1f9a0e2e","target_type":"revision","synthetic":false,"author":{"fullname":"Ned Deily <nad@python.org>","name":"Ned Deily","email":"nad@python.org"},"date":"2017-03-21T02:46:28-04:00","id":"208f61cc7a5dbc9879ae6e5c2f95891e270f09ef","target_url":"https://archive.softwareheritage.org/api/1/revision/69c0db5050f623e8895b72dfe970392b1f9a0e2e/"}
   * récupérer target_type et id
   *
   * *)

  assert false

let get_output url =
  let args = [ url ] in
  OpamSystem.make_command "curl" args @@> function
   { OpamProcess.r_code; OpamProcess.r_stdout; _ } ->
  if r_code <> 0 then Done None else
  let json = String.concat "" r_stdout in
  Done (Some (json_of_string json))

let get_dir hash =
  let url = full_url (Format.sprintf "/vault/directory/%s" hash) in
  get_output url @@+ fun json ->
  let status = find_string "status" json in
  let fetch_url = find_string "fetch_url" json in
  Done (Some (status, fetch_url))

let url_from_rev hash =
  let url = full_url (Format.sprintf "/revision/%s/" hash) in
  get_output url @@+ fun json ->
  match find_string "directory" json with
  | None -> Done None
  | Some d -> get_dir d

let rec url_from_rel hash =
  let url = full_url (Format.sprintf "/release/%s/" hash) in
  get_output url @@+ fun json ->
    match find_string "target" json with
    | None -> Done None
    | Some target ->
      match find_string "target_type" json with
      | None -> Done None
      | Some "release" -> url_from_rel target
      | Some "revision" -> url_from_rev target
      | Some "directory" -> get_dir target
      | _target_type -> Done None
