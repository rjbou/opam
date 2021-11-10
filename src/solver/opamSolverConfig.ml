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
    | BESTEFFORT of bool option
    | BESTEFFORTPREFIXCRITERIA of string option
    | CRITERIA of string option
    | CUDFFILE of string option
    | CUDFTRIM of string option
    | DIGDEPTH of int option
    | EXTERNALSOLVER of string option
    | FIXUPCRITERIA of string option
    | NOASPCUD of bool option
    | PREPRO of bool option
    | SOLVERALLOWSUBOPTIMAL of bool option
    | SOLVERTIMEOUT of float option
    | UPGRADECRITERIA of string option
    | USEINTERNALSOLVER of bool option
    | VERSIONLAGPOWER of int option

  open OpamStd.Config.E
  let besteffort = value (function BESTEFFORT b -> b | _ -> None)
  let besteffortprefixcriteria =
    value (function BESTEFFORTPREFIXCRITERIA s -> s | _ -> None)
  let criteria = value (function CRITERIA s -> s | _ -> None)
  let cudffile = value (function CUDFFILE s -> s | _ -> None)
  let cudftrim = value (function CUDFTRIM s -> s | _ -> None)
  let digdepth = value (function DIGDEPTH i -> i | _ -> None)
  let externalsolver = value (function EXTERNALSOLVER s -> s | _ -> None)
  let fixupcriteria = value (function FIXUPCRITERIA s -> s | _ -> None)
  let noaspcud = value (function NOASPCUD b -> b | _ -> None)
  let prepro = value (function PREPRO b -> b | _ -> None)
  let solverallowsuboptimal =
    value (function SOLVERALLOWSUBOPTIMAL b -> b | _ -> None)
  let solvertimeout = value (function SOLVERTIMEOUT f -> f | _ -> None)
  let useinternalsolver = value (function USEINTERNALSOLVER b -> b | _ -> None)
  let upgradecriteria = value (function UPGRADECRITERIA s -> s | _ -> None)
  let versionlagpower = value (function VERSIONLAGPOWER i -> i | _ -> None)

end

type t = {
  cudf_file: string option;
  solver: (module OpamCudfSolver.S) Lazy.t;
  best_effort: bool;
  (* The following are options because the default can only be known once the
     solver is known, so we set it only if no customisation was made *)
  solver_preferences_default: string option Lazy.t;
  solver_preferences_upgrade: string option Lazy.t;
  solver_preferences_fixup: string option Lazy.t;
  solver_preferences_best_effort_prefix: string option Lazy.t;
  solver_timeout: float option;
  solver_allow_suboptimal: bool;
  cudf_trim: string option;
  dig_depth: int;
  preprocess: bool;
  version_lag_power: int;
}

type 'a options_fun =
  ?cudf_file:string option ->
  ?solver:((module OpamCudfSolver.S) Lazy.t) ->
  ?best_effort:bool ->
  ?solver_preferences_default:string option Lazy.t ->
  ?solver_preferences_upgrade:string option Lazy.t ->
  ?solver_preferences_fixup:string option Lazy.t ->
  ?solver_preferences_best_effort_prefix:string option Lazy.t ->
  ?solver_timeout:float option ->
  ?solver_allow_suboptimal:bool ->
  ?cudf_trim:string option ->
  ?dig_depth:int ->
  ?preprocess:bool ->
  ?version_lag_power:int ->
  'a

let default =
  let solver = lazy (
    OpamCudfSolver.get_solver OpamCudfSolver.default_solver_selection
  ) in
  {
    cudf_file = None;
    solver;
    best_effort = false;
    solver_preferences_default = lazy None;
    solver_preferences_upgrade = lazy None;
    solver_preferences_fixup = lazy None;
    solver_preferences_best_effort_prefix = lazy None;
    solver_timeout = Some 60.;
    solver_allow_suboptimal = true;
    cudf_trim = None;
    dig_depth = 2;
    preprocess = true;
    version_lag_power = 1;
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
      add "cudf_file" (fun r -> r.cudf_file) (fun x -> OS x);
      add "solver" (fun r -> r.solver) (fun x -> Lazy ((fun (module M: OpamCudfSolver.S) -> M.name), x));
      add "best_effort" (fun r -> r.best_effort) (fun x -> B x);
      add "solver_preferences_default" (fun r -> r.solver_preferences_default) (fun x -> OLazy ((fun z -> z), x));
      add "solver_preferences_upgrade" (fun r -> r.solver_preferences_upgrade) (fun x -> OLazy ((fun z -> z), x));
      add "solver_preferences_fixup" (fun r -> r.solver_preferences_fixup) (fun x -> OLazy ((fun z -> z), x));
      add "solver_preferences_best_effort_prefix" (fun r -> r.solver_preferences_best_effort_prefix) (fun x -> OLazy ((fun z -> z), x));
      add "solver_timeout" (fun r -> r.solver_timeout) (fun x -> OF x);
      add "solver_allow_suboptimal" (fun r -> r.solver_allow_suboptimal) (fun x -> B x);
      add "cudf_trim" (fun r -> r.cudf_trim) (fun x -> OS x);
      add "dig_depth" (fun r -> r.dig_depth) (fun x -> I x);
      add "preprocess" (fun r -> r.preprocess) (fun x -> B x);
      add "version_lag_power" (fun r -> r.version_lag_power) (fun x -> I x);
    ]

let setk k t
    ?cudf_file
    ?solver
    ?best_effort
    ?solver_preferences_default
    ?solver_preferences_upgrade
    ?solver_preferences_fixup
    ?solver_preferences_best_effort_prefix
    ?solver_timeout
    ?solver_allow_suboptimal
    ?cudf_trim
    ?dig_depth
    ?preprocess
    ?version_lag_power
  =
  let (+) x opt = match opt with Some x -> x | None -> x in
  let r = {
    cudf_file = t.cudf_file + cudf_file;
    solver = t.solver + solver;
    best_effort = t.best_effort + best_effort;
    solver_preferences_default =
      t.solver_preferences_default + solver_preferences_default;
    solver_preferences_upgrade =
      t.solver_preferences_upgrade + solver_preferences_upgrade;
    solver_preferences_fixup =
      t.solver_preferences_fixup + solver_preferences_fixup;
    solver_preferences_best_effort_prefix =
      t.solver_preferences_best_effort_prefix +
      solver_preferences_best_effort_prefix;
    solver_timeout =
      t.solver_timeout + solver_timeout;
    solver_allow_suboptimal =
      t.solver_allow_suboptimal + solver_allow_suboptimal;
    cudf_trim = t.cudf_trim + cudf_trim;
    dig_depth = t.dig_depth + dig_depth;
    preprocess = t.preprocess + preprocess;
    version_lag_power = t.version_lag_power + version_lag_power;
  } in
  OpamConsole.log_env "solver" (log ~old:t r);
  k r

let set t = setk (fun x () -> x) t

let r = ref default

let update ?noop:_ = setk (fun cfg () -> r := cfg) !r

let with_auto_criteria config =
  let criteria = lazy (
    let module S = (val Lazy.force config.solver) in
    S.default_criteria
  ) in
  set config
    ~solver_preferences_default:
      (lazy (match config.solver_preferences_default with
           | lazy None -> Some (Lazy.force criteria).OpamCudfSolver.crit_default
           | lazy some -> some))
    ~solver_preferences_upgrade:
      (lazy (match config.solver_preferences_upgrade with
           | lazy None -> Some (Lazy.force criteria).OpamCudfSolver.crit_upgrade
           | lazy some -> some))
    ~solver_preferences_fixup:
      (lazy (match config.solver_preferences_fixup with
           | lazy None -> Some (Lazy.force criteria).OpamCudfSolver.crit_fixup
           | lazy some -> some))
    ~solver_preferences_best_effort_prefix:
      (lazy (match config.solver_preferences_best_effort_prefix with
           | lazy None ->
             (Lazy.force criteria).OpamCudfSolver.crit_best_effort_prefix
           | lazy some -> some))
    ()

let initk k =
  let open OpamStd.Option.Op in
  let solver =
    let open OpamCudfSolver in
    match E.externalsolver () with
    | Some "" -> lazy (get_solver ~internal:true default_solver_selection)
    | Some s -> lazy (solver_of_string s)
    | None ->
      let internal = E.useinternalsolver () ++ E.noaspcud () in
      lazy (get_solver ?internal default_solver_selection)
  in
  let criteria =
    E.criteria () >>| fun c -> lazy (Some c) in
  let upgrade_criteria =
    (E.upgradecriteria () >>| fun c -> lazy (Some c)) ++ criteria in
  let fixup_criteria =
    E.fixupcriteria () >>| fun c -> (lazy (Some c)) in
  let best_effort_prefix_criteria =
    E.besteffortprefixcriteria () >>| fun c -> (lazy (Some c)) in
  let solver_timeout =
    E.solvertimeout () >>| fun f -> if f <= 0. then None else Some f in
  setk (setk (fun c -> r := with_auto_criteria c; k)) !r
    ~cudf_file:(E.cudffile ())
    ~solver
    ?best_effort:(E.besteffort ())
    ?solver_preferences_default:criteria
    ?solver_preferences_upgrade:upgrade_criteria
    ?solver_preferences_fixup:fixup_criteria
    ?solver_preferences_best_effort_prefix:best_effort_prefix_criteria
    ?solver_timeout
    ?solver_allow_suboptimal:(E.solverallowsuboptimal ())
    ~cudf_trim:(E.cudftrim ())
    ?dig_depth:(E.digdepth ())
    ?preprocess:(E.prepro ())
    ?version_lag_power:(E.versionlagpower ())

let init ?noop:_ = initk (fun () -> ())

let best_effort =
  let r = lazy (
    !r.best_effort &&
    let crit = match Lazy.force !r.solver_preferences_default with
      | Some c -> c
      | None -> failwith "Solver criteria uninitialised"
    in
    let pfx = Lazy.force !r.solver_preferences_best_effort_prefix in
    pfx <> None ||
    OpamStd.String.contains ~sub:"opam-query" crit ||
    (OpamConsole.warning
       "Your solver configuration does not support --best-effort, the option \
        was ignored (you need to specify variable OPAMBESTEFFORTCRITERIA, or \
        set your criteria to maximise the count for cudf attribute \
        'opam-query')";
     false)
  ) in
  fun () -> Lazy.force r

let criteria kind =
  let crit = match kind with
    | `Default -> !r.solver_preferences_default
    | `Upgrade -> !r.solver_preferences_upgrade
    | `Fixup -> !r.solver_preferences_fixup
  in
  let str =
    match Lazy.force crit with
    | Some c -> c
    | None -> failwith "Solver criteria uninitialised"
  in
  if !r.best_effort then
    match !r.solver_preferences_best_effort_prefix with
    | lazy (Some pfx) -> pfx ^ str
    | lazy None -> str
  else str

let call_solver ~criteria cudf =
  let module S = (val Lazy.force (!r.solver)) in
  OpamConsole.log "SOLVER" "Calling solver %s with criteria %s"
    (OpamCudfSolver.get_name (module S)) criteria;
  S.call ~criteria ?timeout:(!r.solver_timeout) cudf
