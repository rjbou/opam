(**************************************************************************)
(*                                                                        *)
(*    Copyright 2015-2019 OCamlPro                                        *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

open OpamTypes

module E = struct

  type OpamStd.Config.E.t +=
    | CURL of string option
    | FETCH of string option
    | NOCHECKSUMS of bool option
    | REQUIRECHECKSUMS of bool option
    | RETRIES of int option
    | VALIDATIONHOOK of string option

  open OpamStd.Config.E
  let curl = value (function CURL s -> s | _ -> None)
  let fetch = value (function FETCH s -> s | _ -> None)
  let nochecksums = value (function NOCHECKSUMS b -> b | _ -> None)
  let requirechecksums = value (function REQUIRECHECKSUMS b -> b | _ -> None)
  let retries = value (function RETRIES i -> i | _ -> None)
  let validationhook = value (function VALIDATIONHOOK s -> s | _ -> None)

end

type dl_tool_kind = [ `Curl | `Default ]

type t = {
  download_tool: (arg list * dl_tool_kind) Lazy.t;
  validation_hook: arg list option;
  retries: int;
  force_checksums: bool option;
}

type 'a options_fun =
  ?download_tool:(OpamTypes.arg list * dl_tool_kind) Lazy.t ->
  ?validation_hook:arg list option ->
  ?retries:int ->
  ?force_checksums:bool option ->
  'a

let default = {
  download_tool = lazy (
    let os = OpamStd.Sys.os () in
    try
      let curl = "curl", `Curl in
      let tools =
        match os with
        | Darwin  -> ["wget", `Default; curl]
        | FreeBSD -> ["fetch", `Default ; curl]
        | OpenBSD -> ["ftp", `Default; curl]
        | _ -> [curl; "wget", `Default]
      in
      let cmd, kind =
        List.find (fun (c,_) -> OpamSystem.resolve_command c <> None) tools
      in
      [ CIdent cmd, None ], kind
    with Not_found ->
      OpamConsole.error_and_exit `Configuration_error
        "Could not find a suitable download command. Please make sure you \
         have %s installed, or specify a custom command through variable \
         OPAMFETCH."
        (match os with
         | FreeBSD -> "fetch"
         | OpenBSD -> "ftp"
         | _ -> "either \"curl\" or \"wget\"")
  );
  validation_hook = None;
  retries = 3;
  force_checksums = None;
}

let log =
  let fst = ref true in
  fun ?old r ->
    let old = if !fst then (fst:= false; None) else old in
    let add label get le =
      match old with
      | Some o when try get o = get r with Invalid_argument _ -> false -> None
      | _ -> Some (label, le (get r))
    in
    OpamStd.List.filter_map (fun x -> x) @@
    OpamStd.Log.[
      add "download_tool" (fun r -> r.download_tool) (fun x -> Lazy ((fun (_args, tool) -> match tool with | `Curl -> "curl" | `Default -> "default"), x));
      add "validation_hook" (fun r -> r.validation_hook) (fun x -> OS (OpamStd.Option.map (fun _ -> "todo") x));
      add "retries" (fun r -> r.retries) (fun x -> I x);
      add "force_checksums" (fun r -> r.force_checksums) (fun x -> OB x);
    ]

let setk k t
    ?download_tool
    ?validation_hook
    ?retries
    ?force_checksums
  =
  let (+) x opt = match opt with Some x -> x | None -> x in
  let r = {
    download_tool = t.download_tool + download_tool;
    validation_hook = t.validation_hook + validation_hook;
    retries = t.retries + retries;
    force_checksums = t.force_checksums + force_checksums;
  } in
  OpamConsole.log_env "repository" (log ~old:t r);
  k r

let set t = setk (fun x () -> x) t

let r = ref default

let update ?noop:_ = setk (fun cfg () -> r := cfg) !r

let initk k =
  let open OpamStd.Option.Op in
  let download_tool =
    E.fetch () >>= (fun s ->
        let args = OpamStd.String.split s ' ' in
        match args with
        | cmd::a ->
          let cmd, kind =
            if OpamStd.String.ends_with ~suffix:"curl" cmd then
              (CIdent "curl", None), `Curl
            else if cmd = "wget" then
              (CIdent "wget", None), `Default
            else
              (CString cmd, None), `Default
          in
          let c = cmd :: List.map (fun a -> OpamTypes.CString a, None) a in
          Some (lazy (c, kind))
        | [] ->
          None
      )
    >>+ fun () ->
    E.curl () >>| (fun s ->
        lazy ([CString s, None], `Curl))
  in
  let validation_hook =
    E.validationhook () >>| fun s ->
    match List.map (fun s -> CString s, None) (OpamStd.String.split s ' ') with
    | [] -> None
    | l -> Some l
  in
  let force_checksums =
    match E.requirechecksums (), E.nochecksums () with
    | Some true, _ -> Some (Some true)
    | _, Some true -> Some (Some false)
    | None, None -> None
    | _ -> Some None
  in
  setk (setk (fun c -> r := c; k)) !r
    ?download_tool
    ?validation_hook
    ?retries:(E.retries ())
    ?force_checksums

let init ?noop:_ = initk (fun () -> ())
