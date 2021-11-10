(**************************************************************************)
(*                                                                        *)
(*    Copyright 2015-2018 OCamlPro                                        *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

module E = struct

  type OpamStd.Config.E.t +=
    | COLOR of OpamStd.Config.when_ option
    | CONFIRMLEVEL of OpamStd.Config.answer option
    | DEBUG of int option
    | DEBUGSECTIONS of OpamStd.Config.sections option
    | ERRLOGLEN of int option
    | KEEPLOGS of bool option
    | LOGS of string option
    | MERGEOUT of bool option
    | NO of bool option
    | PRECISETRACKING of bool option
    | SAFE of bool option
    | STATUSLINE of OpamStd.Config.when_ option
    | USEOPENSSL of bool option
    | UTF8 of OpamStd.Config.when_ext option
    | UTF8MSGS of bool option
    | VERBOSE of OpamStd.Config.level option
    | YES of bool option

  open OpamStd.Config.E
  let color = value (function COLOR w -> w | _ -> None)
  let confirmlevel = value (function CONFIRMLEVEL a -> a | _ -> None)
  let debug = value (function DEBUG i -> i | _ -> None)
  let debugsections = value (function DEBUGSECTIONS s -> s | _ -> None)
  let errloglen = value (function ERRLOGLEN i -> i | _ -> None)
  let keeplogs = value (function KEEPLOGS b -> b | _ -> None)
  let logs = value (function LOGS s -> s | _ -> None)
  let mergeout = value (function MERGEOUT b -> b | _ -> None)
  let no = value (function NO b -> b | _ -> None)
  let precisetracking = value (function PRECISETRACKING b -> b | _ -> None)
  let safe = value (function SAFE b -> b | _ -> None)
  let statusline = value (function STATUSLINE w -> w | _ -> None)
  let useopenssl = value (function USEOPENSSL b -> b | _ -> None)
  let utf8 = value (function UTF8 c -> c | _ -> None)
  let utf8msgs = value (function UTF8MSGS b -> b | _ -> None)
  let verbose = value (function VERBOSE l -> l | _ -> None)
  let yes = value (function YES b -> b | _ -> None)

end

type t = {
  debug_level: OpamStd.Config.level;
  debug_sections: OpamStd.Config.sections;
  verbose_level: OpamStd.Config.level;
  color: OpamStd.Config.when_;
  utf8: OpamStd.Config.when_ext;
  disp_status_line: OpamStd.Config.when_;
  confirm_level: [ OpamStd.Config.answer | `undefined ];
  yes: bool option;
  safe_mode: bool;
  log_dir: string;
  keep_log_dir: bool;
  errlog_length: int;
  merged_output: bool;
  use_openssl: bool;
  precise_tracking: bool;
  set: bool;
}

type 'a options_fun =
  ?debug_level:OpamStd.Config.level ->
  ?debug_sections:OpamStd.Config.sections ->
  ?verbose_level:OpamStd.Config.level ->
  ?color:OpamStd.Config.when_ ->
  ?utf8:OpamStd.Config.when_ext ->
  ?disp_status_line:OpamStd.Config.when_ ->
  ?confirm_level:OpamStd.Config.answer ->
  ?yes:bool option ->
  ?safe_mode:bool ->
  ?log_dir:string ->
  ?keep_log_dir:bool ->
  ?errlog_length:int ->
  ?merged_output:bool ->
  ?use_openssl:bool ->
  ?precise_tracking:bool ->
  'a

let default = {
  debug_level = 0;
  debug_sections = OpamStd.String.Map.empty;
  verbose_level = 0;
  color = `Auto;
  utf8 = `Auto;
  disp_status_line = `Auto;
  confirm_level = `undefined;
  yes = None;
  safe_mode = false;
  log_dir =
    (let user = try Unix.getlogin() with Unix.Unix_error _ -> "xxx" in
     let base = Printf.sprintf "opam-%s-%d" user (OpamStubs.getpid()) in
     Filename.(concat (get_temp_dir_name ()) base));
  keep_log_dir = false;
  errlog_length = 12;
  merged_output = true;
  use_openssl = true;
  precise_tracking = false;
  set = false;
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
      add "debug_level" (fun r -> r.debug_level) (fun x -> I x);
      add "debug_sections" (fun r -> r.debug_sections) (fun x -> Custom (OpamStd.String.Map.to_string (OpamStd.Option.to_string string_of_int), x));
      add "verbose_level" (fun r -> r.verbose_level) (fun x -> I x);
      add "color" (fun r -> r.color) (fun x -> CustomO (OpamStd.Config.string_of_when, x));
      add "utf8" (fun r -> r.utf8) (fun x -> CustomO (OpamStd.Config.string_of_when_ext, x));
      add "disp_status_line" (fun r -> r.disp_status_line) (fun x -> CustomO (OpamStd.Config.string_of_when, x));
      add "confirm_level" (fun r -> r.confirm_level) (fun x -> CustomO ((function | `undefined -> Some "undefined" | #OpamStd.Config.answer as z -> OpamStd.Config.string_of_answer z) , x));
      add "yes" (fun r -> r.yes) (fun x -> OB x);
      add "safe_mode" (fun r -> r.safe_mode) (fun x -> B x);
      add "log_dir" (fun r -> r.log_dir) (fun x -> S x);
      add "keep_log_dir" (fun r -> r.keep_log_dir) (fun x -> B x);
      add "errlog_length" (fun r -> r.errlog_length) (fun x -> I x);
      add "merged_output" (fun r -> r.merged_output) (fun x -> B x);
      add "use_openssl" (fun r -> r.use_openssl) (fun x -> B x);
      add "precise_tracking" (fun r -> r.precise_tracking) (fun x -> B x);
    ]

let setk k t
    ?debug_level
    ?debug_sections
    ?verbose_level
    ?color
    ?utf8
    ?disp_status_line
    ?confirm_level
    ?yes
    ?safe_mode
    ?log_dir
    ?keep_log_dir
    ?errlog_length
    ?merged_output
    ?use_openssl
    ?precise_tracking
  =
  let (+) x opt = match opt with Some x -> x | None -> x in
  let r = {
    debug_level = t.debug_level + debug_level;
    debug_sections = t.debug_sections + debug_sections;
    verbose_level = t.verbose_level + verbose_level;
    color = t.color + color;
    utf8 = t.utf8 + utf8;
    disp_status_line = t.disp_status_line + disp_status_line;
    confirm_level =
      (match confirm_level with
       | Some (`all_yes|`all_no|`ask|`unsafe_yes as c) -> c
       | None ->  t.confirm_level);
    yes = t.yes + yes;
    safe_mode = t.safe_mode + safe_mode;
    log_dir = t.log_dir + log_dir;
    keep_log_dir = t.keep_log_dir + keep_log_dir;
    errlog_length = t.errlog_length + errlog_length;
    merged_output = t.merged_output + merged_output;
    use_openssl = t.use_openssl + use_openssl;
    precise_tracking = t.precise_tracking + precise_tracking;
    set = true;
  } in
  if r <> t then OpamStd.Log.log_env "core" (log ~old:t r);
  k r


let set t = setk (fun x () -> x) t

(* Global configuration reference *)

let r = ref default

let update ?noop:_ = setk (fun cfg () -> r := cfg) !r

let initk k =
  let open OpamStd in
  let utf8 = Option.Op.(
      E.utf8 () ++
      (E.utf8msgs () >>= function
        | true -> Some `Extended
        | false -> None)
    ) in
  let yes =
    match E.yes (), E.no () with
    | Some true, _ -> Some (Some true)
    | _, Some true -> Some (Some false)
    | _, _ -> None
  in
  (setk (setk (fun c -> r := c; k)) !r)
    ?debug_level:(E.debug ())
    ?debug_sections:(E.debugsections ())
    ?verbose_level:(E.verbose ())
    ?color:(E.color ())
    ?utf8
    ?disp_status_line:(E.statusline ())
    ?confirm_level:(E.confirmlevel ())
    ?yes
    ?safe_mode:(E.safe ())
    ?log_dir:(E.logs ())
    ?keep_log_dir:(E.keeplogs ())
    ?errlog_length:(E.errloglen ())
    ?merged_output:(E.mergeout ())
    ?use_openssl:(E.useopenssl ())
    ?precise_tracking:(E.precisetracking ())

let init ?noop:_ = initk (fun () -> ())

let answer () =
  match !r.confirm_level, !r.yes with
  | #OpamStd.Config.answer as c, _ -> c
  | _, Some true -> `all_yes
  | _, Some false -> `all_no
  | _ -> `ask

let answer_is =
  let answer = lazy (answer ()) in
  fun a -> Lazy.force answer = a

let answer_is_yes () =
  answer_is `all_yes || answer_is `unsafe_yes

#ifdef DEVELOPER
let developer = true
#else
let developer = false
#endif
