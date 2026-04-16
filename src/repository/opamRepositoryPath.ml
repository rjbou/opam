(**************************************************************************)
(*                                                                        *)
(*    Copyright 2012-2019 OCamlPro                                        *)
(*    Copyright 2012 INRIA                                                *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

open OpamFilename.Op

let pin_cache_dir =
  let dir =
    lazy (OpamSystem.mk_temp_dir ~prefix:"opam-pin-cache" ()
          |> OpamFilename.Dir.of_string )
  in
  fun () -> Lazy.force dir

let pin_cache u =
  pin_cache_dir () /
  String.sub
    (OpamHash.contents @@
     OpamHash.compute_from_string ~kind:`SHA512 @@
     OpamUrl.to_string u)
    0 16

module Names = struct
  let repo = "repo"
  let repo_f = "repo"
  let packages = "packages"
  let download_cache = "download-cache"
  let files = "files"
end

let download_cache root = root / Names.download_cache

let install_nv_dir filename =
  let rec find_files prefix_files tail =
    match tail with
    | files::_ when String.equal files Names.files -> Some prefix_files
    | h::t -> find_files (h::prefix_files) t
    | [] -> None
  in
  let rec aux (pre, rest) =
    match rest with
    | p::packages when String.equal p Names.packages ->
      (* We don't check packages/name/name.version layer because repo loading
         is more permissive *)
      (match find_files [] packages with
       | Some (nv::prefix_files) ->
         (match OpamPackage.of_string_opt nv with
          | Some pkg ->
            let dir =
              (*(List.rev (nv :: prefix_files @ (Names.packages::pre))) *)
              List.rev (nv :: prefix_files @ [Names.packages])
              |> OpamFilename.Dir.of_list
              |> OpamFilename.Raw.Dir.of_dir
            in
            Some (pkg, dir)
          | None -> None)
       | None | Some [] -> None)
    | p::r -> aux (p::pre, r)
    | [] -> None
  in
  aux ([], OpamFilename.to_list (OpamFilename.Raw.to_filename filename))

module Remote = struct
  (** URL, not FS paths *)
  open OpamUrl.Op

  let repo root_url =
    root_url / Names.repo_f

  let packages_url root_url =
    root_url / Names.packages

  let archive root_url nv =
    root_url / "archives" / (OpamPackage.to_string nv ^ "+opam.tar.gz")
end
