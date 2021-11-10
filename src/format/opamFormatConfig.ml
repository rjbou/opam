(**************************************************************************)
(*                                                                        *)
(*    Copyright 2015-2016 OCamlPro                                        *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

module E = struct

  type OpamStd.Config.E.t +=
    | ALLPARENS of bool option
    | SKIPVERSIONCHECKS of bool option
    | STRICT of bool option

  open OpamStd.Config.E
  let allparens = value (function ALLPARENS b -> b | _ -> None)
  let skipversionchecks = value (function SKIPVERSIONCHECKS b -> b | _ -> None)
  let strict = value (function STRICT b -> b | _ -> None)

end

type t = {
  strict: bool;
  skip_version_checks: bool;
  all_parens: bool;
}

type 'a options_fun =
  ?strict:bool ->
  ?skip_version_checks:bool ->
  ?all_parens:bool ->
  'a

let default = {
  strict = false;
  skip_version_checks = false;
  all_parens = false;
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
      add "strict" (fun r -> r.strict) (fun x -> B x);
      add "skip_version_checks" (fun r -> r.skip_version_checks) (fun x -> B x);
      add "all_parens" (fun r -> r.all_parens) (fun x -> B x);
    ]

let setk k t
    ?strict
    ?skip_version_checks
    ?all_parens
  =
  let (+) x opt = match opt with Some x -> x | None -> x in
  let r = {
    strict = t.strict + strict;
    skip_version_checks = t.skip_version_checks + skip_version_checks;
    all_parens = t.all_parens + all_parens;
  } in
  if r <> t then OpamConsole.log_env "format" (log ~old:t r);
  k r

let set t = setk (fun x () -> x) t

(* Global configuration reference *)

let r = ref default

let update ?noop:_ = setk (fun cfg () -> r := cfg) !r

let initk k =
  setk (setk (fun c -> r := c; k)) !r
    ?strict:(E.strict ())
    ?skip_version_checks:(E.skipversionchecks ())
    ?all_parens:(E.allparens ())

let init ?noop:_ = initk (fun () -> ())
