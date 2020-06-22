(**************************************************************************)
(*                                                                        *)
(*    Copyright 2012-2018 OCamlPro                                        *)
(*    Copyright 2012 INRIA                                                *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

include OpamStd.AbstractString

let unset = of_string "#unset#"

let is_external s =
  OpamStd.String.starts_with ~prefix:"." s ||
  OpamStd.String.contains ~sub:Filename.dir_sep s

let external_dirname = "_opam"

let check s =
  let re =
    Re.(compile @@
        seq [
          bol;
          opt @@ seq [ wordc ; char ':'; char '/' ];
          rep1 @@ diff any @@ set "<>!`$():";
          eol
        ])
  in
  (try ignore @@ Re.exec re s with Not_found ->
     failwith (Printf.sprintf "Invalid character in switch name %S" s));
  s

let of_string s =
  check @@
  if is_external s then OpamFilename.Dir.(to_string (of_string s))
  else s

let of_dirname d =
  let s = OpamFilename.Dir.to_string d in
  check @@
  try
    let swdir = Unix.readlink (Filename.concat s external_dirname) in
    let swdir =
      if Filename.is_relative swdir then Filename.concat s swdir else swdir
    in
    let r = OpamSystem.real_path swdir in
    if Filename.basename r = external_dirname then Filename.dirname r else s
  with Unix.Unix_error _ -> s

let get_root root s =
  if is_external s
  then OpamFilename.Dir.of_string (Filename.concat s external_dirname)
  else OpamFilename.Op.(root / s)



(*
let lst =
  [
    "C:/toto" ;
    "C:/toto/foo" ;
    "C:/toto:titi/foo";
    "./hello/lmp";
    "./hello/ld:mp";
    "/tlo/prefx/./hello/lmp";
    "/tlo/prefx/./hello/ld:mp";
    "/tlo/prefx//hello/lmp";
    "/tlo/prefx//hello/ld<mp";
  ]
;;


;;


List.map (fun s ->
    let res =
      try
        let r = try Re.(exec re s) with Not_found -> failwith "EXEC" in
(*         Re.(Group.get r 0) *)
Re.matches re s
      with Not_found -> ["GROUP"]
         | Failure s -> [s]
    in
    s,res
  ) lst
;;
*)
