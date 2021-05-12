(**************************************************************************)
(*                                                                        *)
(*    Copyright 2015-2020 OCamlPro                                        *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

open OpamTypes
open OpamStateTypes

module E = struct

  type OpamStd.Config.E.t +=
    | BUILDDOC of bool option
    | BUILDTEST of bool option
    | DEPEXTYES of bool option
    | DOWNLOADJOBS of int option
    | DRYRUN of bool option
    | IGNORECONSTRAINTS of string option
    | JOBS of int option
    | LOCKED of string option
    | MAKECMD of string option
    | NODEPEXTS of bool option
    | NOENVNOTICE of bool option
    | ROOT of string option
    | SWITCH of string option
    | UNLOCKBASE of bool option
    | WITHDOC of bool option
    | WITHTEST of bool option

  open OpamStd.Config.E
  let builddoc = value (function BUILDDOC b -> b | _ -> None)
  let buildtest = value (function BUILDTEST b -> b | _ -> None)
  let depextyes = value (function DEPEXTYES b -> b | _ -> None)
  let downloadjobs = value (function DOWNLOADJOBS i -> i | _ -> None)
  let dryrun = value (function DRYRUN b -> b | _ -> None)
  let ignoreconstraints = value (function IGNORECONSTRAINTS s -> s | _ -> None)
  let jobs = value (function JOBS i -> i | _ -> None)
  let locked = value (function LOCKED s -> s | _ -> None)
  let makecmd = value (function MAKECMD s -> s | _ -> None)
  let nodepexts = value (function NODEPEXTS b -> b | _ -> None)
  let noenvnotice = value (function NOENVNOTICE b -> b | _ -> None)
  let root = value (function ROOT s -> s | _ -> None)
  let switch = value (function SWITCH s -> s | _ -> None)
  let unlockbase = value (function UNLOCKBASE b -> b | _ -> None)
  let withdoc = value (function WITHDOC b -> b | _ -> None)
  let withtest = value (function WITHTEST b -> b | _ -> None)

end

type t = {
  root_dir: OpamFilename.Dir.t;
  current_switch: OpamSwitch.t option;
  switch_from: provenance;
  jobs: int Lazy.t;
  dl_jobs: int;
  build_test: bool;
  build_doc: bool;
  dryrun: bool;
  makecmd: string Lazy.t;
  ignore_constraints_on: name_set;
  unlock_base: bool;
  no_env_notice: bool;
  locked: string option;
  no_depexts: bool;
  depext_yes: bool;
}

let default = {
  root_dir = OpamFilename.(
      concat_and_resolve (Dir.of_string (OpamStd.Sys.home ())) ".opam"
    );
  current_switch = None;
  switch_from = `Default;
  jobs = lazy (max 1 (OpamSysPoll.cores () - 1));
  dl_jobs = 3;
  build_test = false;
  build_doc = false;
  dryrun = false;
  makecmd = lazy OpamStd.Sys.(
      match os () with
      | FreeBSD | OpenBSD | NetBSD | DragonFly -> "gmake"
      | _ -> "make"
    );
  ignore_constraints_on = OpamPackage.Name.Set.empty;
  unlock_base = false;
  no_env_notice = false;
  locked = None;
  no_depexts = false;
  depext_yes = false;
}

type 'a options_fun =
  ?root_dir:OpamFilename.Dir.t ->
  ?current_switch:OpamSwitch.t ->
  ?switch_from:provenance ->
  ?jobs:(int Lazy.t) ->
  ?dl_jobs:int ->
  ?build_test:bool ->
  ?build_doc:bool ->
  ?dryrun:bool ->
  ?makecmd:string Lazy.t ->
  ?ignore_constraints_on:name_set ->
  ?unlock_base:bool ->
  ?no_env_notice:bool ->
  ?locked:string option ->
  ?no_depexts: bool ->
  ?depext_yes: bool ->
  'a

let setk k t
    ?root_dir
    ?current_switch
    ?switch_from
    ?jobs
    ?dl_jobs
    ?build_test
    ?build_doc
    ?dryrun
    ?makecmd
    ?ignore_constraints_on
    ?unlock_base
    ?no_env_notice
    ?locked
    ?no_depexts
    ?depext_yes
  =
  let (+) x opt = match opt with Some x -> x | None -> x in
  k {
    root_dir = t.root_dir + root_dir;
    current_switch =
      (match current_switch with None -> t.current_switch | s -> s);
    switch_from = t.switch_from + switch_from;
    jobs = t.jobs + jobs;
    dl_jobs = t.dl_jobs + dl_jobs;
    build_test = t.build_test + build_test;
    build_doc = t.build_doc + build_doc;
    dryrun = t.dryrun + dryrun;
    makecmd = t.makecmd + makecmd;
    ignore_constraints_on = t.ignore_constraints_on + ignore_constraints_on;
    unlock_base = t.unlock_base + unlock_base;
    no_env_notice = t.no_env_notice + no_env_notice;
    locked = t.locked + locked;
    no_depexts = t.no_depexts + no_depexts;
    depext_yes = t.depext_yes + depext_yes;
  }

let set t = setk (fun x () -> x) t

let r = ref default

let update ?noop:_ = setk (fun cfg () -> r := cfg) !r

let initk k =
  let open OpamStd.Option.Op in
  let current_switch, switch_from =
    match E.switch () with
    | Some "" | None -> None, None
    | Some s -> Some (OpamSwitch.of_string s), Some `Env
  in
  setk (setk (fun c -> r := c; k)) !r
    ?root_dir:(E.root () >>| OpamFilename.Dir.of_string)
    ?current_switch
    ?switch_from
    ?jobs:(E.jobs () >>| fun s -> lazy s)
    ?dl_jobs:(E.downloadjobs ())
    ?build_test:(E.withtest () ++ E.buildtest ())
    ?build_doc:(E.withdoc () ++ E.builddoc ())
    ?dryrun:(E.dryrun ())
    ?makecmd:(E.makecmd () >>| fun s -> lazy s)
    ?ignore_constraints_on:
      (E.ignoreconstraints () >>| fun s ->
       OpamStd.String.split s ',' |>
       List.map OpamPackage.Name.of_string |>
       OpamPackage.Name.Set.of_list)
    ?unlock_base:(E.unlockbase ())
    ?no_env_notice:(E.noenvnotice ())
    ?locked:(E.locked () >>| function "" -> None | s -> Some s)
    ?no_depexts:(E.nodepexts ())
    ?depext_yes:(E.depextyes ())

let init ?noop:_ = initk (fun () -> ())

let opamroot ?root_dir () =
  let open OpamStd.Option.Op in
  (root_dir >>+ fun () ->
   OpamStd.Env.getopt "OPAMROOT" >>| OpamFilename.Dir.of_string)
  +! default.root_dir

(* XXX Keep here or move to OpamFile.Config *)
let more_recent_raw version =
  match version with
  | Some v ->
    OpamVersion.compare v OpamFile.Config.root_version > 0
  | None -> false

let more_recent config =
    more_recent_raw (OpamFile.Config.opam_root_version config)

(** none -> shouldn't load (write attempt in readonly)
    Some true -> everything is fine normal read
    Some false -> readonly accorded, load with best effort *)
let is_readonly_opamroot_raw ?(lock_kind=`Lock_write) version =
(*
  let newer = more_recent_raw version in
  let write = lock_kind = `Lock_write in
  if newer && write then None else
    Some (newer && not write)
*)
  let write = lock_kind = `Lock_write in
  let newer = more_recent_raw version in
  let older = 
    match version with
    | Some v ->
      OpamVersion.compare v OpamFile.Config.root_version < 0
    | None -> true 
  in
(*
  OpamConsole.error "older %B newer %B version is %s"
  older newer
  (OpamStd.Option.to_string OpamVersion.to_string version );
*)
  if (older || newer) && write then None else
    Some ((older || newer) && not write) 

let is_readonly_opamroot_t ?lock_kind gt =
  is_readonly_opamroot_raw ?lock_kind
    (OpamFile.Config.opam_root_version gt.config)

let is_readonly_opamroot ?lock_kind gt =
  is_readonly_opamroot_t ?lock_kind gt <> Some false

let load_if_possible_raw ?lock_kind version (read,read_wo_err) f =
  match is_readonly_opamroot_raw ?lock_kind version with
  | None ->
    OpamConsole.error_and_exit `Configuration_error
      "Write lock and root more recent, abort!"
  | Some true -> 
(*   OpamConsole.error "read wo err"; *)
  read_wo_err f
  | Some false -> 
(*   OpamConsole.error "read normal"; *)
  read f

let load_if_possible_t ?lock_kind config readf f =
  load_if_possible_raw ?lock_kind
    (OpamFile.Config.opam_root_version config) readf f

let load_if_possible ?lock_kind gt =
  load_if_possible_t ?lock_kind gt.config

let load_config_root ?lock_kind readf opamroot =
  let f = OpamPath.config opamroot in
  load_if_possible_raw ?lock_kind
    (OpamFile.Config.raw_root_version f)
    readf f

let safe_load ?lock_kind opamroot =
  load_config_root ?lock_kind
    OpamFile.Config.(safe_read, NoError.safe_read) opamroot

let load ?lock_kind opamroot =
  load_config_root ?lock_kind
    OpamFile.Config.(read_opt, NoError.read_opt) opamroot

exception Need_root_upgrade of OpamFile.Config.t

(* switches *)
module Switch = struct

  let tweak421 ?(lock_kind=`Lock_write) config =
    if OpamFile.Config.opam_root_version config = None
    && lock_kind = `Lock_write then
(*       let _ = OpamConsole.error "need to upgrade root" in *)
      raise (Need_root_upgrade config)


  let load_raw ?lock_kind root config readf switch =
    tweak421 ?lock_kind config;
    load_if_possible_t ?lock_kind config readf
      (OpamPath.Switch.switch_config root switch)

  let safe_load_t ?lock_kind root switch =
    let config = safe_load ~lock_kind:`Lock_read root in
    tweak421 ?lock_kind config;
    load_raw ?lock_kind root config
      OpamFile.Switch_config.(safe_read, NoError.safe_read)
      switch

  let load ?lock_kind gt readf switch =
    let config = safe_load ~lock_kind:`Lock_read gt.root in
    tweak421 ?lock_kind config;
    load_if_possible_t ?lock_kind config readf
      (OpamPath.Switch.switch_config gt.root switch)

  let safe_load ?lock_kind gt switch =
    load ?lock_kind gt
      OpamFile.Switch_config.(safe_read, NoError.safe_read)
      switch

  let read_opt ?lock_kind gt switch =
    load ?lock_kind gt
      OpamFile.Switch_config.(read_opt, NoError.read_opt)
      switch

  let safe_read_selections ?lock_kind gt switch =
    load_if_possible ?lock_kind gt
      OpamFile.SwitchSelections.(safe_read, NoError.safe_read)
      (OpamPath.Switch.selections gt.root switch)

end

(* repos *)
module Repos = struct
  let safe_read ?lock_kind gt =
    load_if_possible ?lock_kind gt
      OpamFile.Repos_config.(safe_read, NoError.safe_read)
      (OpamPath.repos_config gt.root)
end

let local_switch_exists root switch =
  (* we don't use safe loading function to avoid several errors display *)
  OpamPath.Switch.switch_config root switch |>
  OpamFile.Switch_config.NoError.read_opt |> function
  | None -> false
  | Some conf -> conf.OpamFile.Switch_config.opam_root = Some root
(*
  let conf = safe_load_switch_config_t ~lock_kind:`Lock_read root switch in
  conf.OpamFile.Switch_config.opam_root = Some root
*)

let resolve_local_switch root s =
  let switch_root = OpamSwitch.get_root root s in
  if OpamSwitch.is_external s && OpamFilename.dirname_dir switch_root = root
  then OpamSwitch.of_string (OpamFilename.remove_prefix_dir root switch_root)
  else s

let get_current_switch_from_cwd root =
  let open OpamStd.Option.Op in
  OpamFilename.find_in_parents (fun dir ->
      OpamSwitch.of_string (OpamFilename.Dir.to_string dir) |>
      local_switch_exists root)
    (OpamFilename.cwd ())
  >>| OpamSwitch.of_dirname
  >>| resolve_local_switch root

let load_defaults ?lock_kind root_dir =
  let current_switch =
    match E.switch () with
    | Some "" | None -> get_current_switch_from_cwd root_dir
    | _ -> (* OPAMSWITCH is set, no need to lookup *) None
  in
  match load ?lock_kind root_dir with
  | None ->
    update ?current_switch ();
    None
  | Some conf ->
    let open OpamStd.Option.Op in
    OpamRepositoryConfig.update
      ?download_tool:(OpamFile.Config.dl_tool conf >>| function
        | (CString c,None)::_ as t
          when OpamStd.String.ends_with ~suffix:"curl" c -> lazy (t, `Curl)
        | t -> lazy (t, `Default))
      ~validation_hook:(OpamFile.Config.validation_hook conf)
      ();
    update
      ?current_switch:(OpamFile.Config.switch conf)
      ~switch_from:`Default
      ?jobs:(OpamFile.Config.jobs conf >>| fun s -> lazy s)
      ~dl_jobs:(OpamFile.Config.dl_jobs conf)
      ();
    update ?current_switch ();
    Some conf

let get_switch_opt () =
  match !r.current_switch with
  | Some s ->
    Some (resolve_local_switch !r.root_dir s)
  | None -> None

let get_switch () =
  match get_switch_opt () with
  | Some s -> s
  | None ->
    OpamConsole.error_and_exit `Configuration_error
      "No switch is currently set. Please use 'opam switch' to set or install \
       a switch"
