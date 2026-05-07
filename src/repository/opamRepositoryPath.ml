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

let download_cache root = root / OpamRepositoryPathName.download_cache_d

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




module Remote = struct
  (** URL, not FS paths *)
  open OpamUrl.Op

  let repo root_url =
    root_url / OpamRepositoryPathName.repo_f

  let packages_url root_url =
    root_url / OpamRepositoryPathName.packages_d

  let archive root_url nv =
    root_url / "archives" / (OpamPackage.to_string nv ^ "+opam.tar.gz")
end
