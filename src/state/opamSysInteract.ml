(**************************************************************************)
(*                                                                        *)
(*    Copyright 2019 OCamlPro                                             *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

(* Run commands *)
let run_command ?(discard_err=false) cmd args =
  let stdout = if discard_err then Some "query_out" else None in
  let open OpamProcess.Job.Op in
  OpamProcess.Job.run @@ OpamSystem.make_command ?stdout cmd args
  @@> fun r ->
  let code = r.r_code in
  let out = r.r_stdout in
  OpamProcess.cleanup r;
  Done (code, out)

let run_query_command cmd args =
  let code,out = run_command cmd args in
  if code = 0 then out
  else []

let run_command_exit_code cmd args =
  let code,_ = run_command cmd args in
  code

(* System status *)
let spv f = OpamStd.Option.Op.(f () +! "unknown")

let packages_status packages =
  let open OpamSysPkg.Set.Op in
  let from_system lines get =
    let installed, available =
      List.fold_left get OpamSysPkg.Set.(empty, empty) lines
    in
    let not_found = packages -- installed -- available in
    installed, available, not_found
  in
  let installed, available, not_found =
    match spv OpamSysPoll.os_family with
    | "alpine" ->
      let lines =
        run_query_command "apk" ["list";"--available"]
      in
      let re_installed = Re.(compile (seq [str "[installed]"; eol])) in
      let re_pkg =
        (* packages form : libpeas-python3-1.22.0-r1 *)
        Re.(compile @@ seq
              [ bol;
                group @@ rep1 @@ alt [alnum; punct];
                char '-';
                rep1 digit;
                rep any ])
      in
      from_system lines
        (fun (inst,avail) l ->
           try
             let pkg = OpamSysPkg.of_string (Re.(Group.get (exec re_pkg l) 1)) in
             if OpamSysPkg.Set.mem pkg packages then
               if Re.execp re_installed l then
                 OpamSysPkg.Set.add pkg inst, avail
               else
                 inst, OpamSysPkg.Set.add pkg avail
             else inst, avail
           with Not_found -> inst, avail)
    | "amzn" | "centos" | "fedora" | "mageia" | "oraclelinux" | "ol" | "rhel" ->
      (* XXX /!\ only checked on centos XXX *)
      let lines = run_query_command "yum" ["-q"; "-C"; "list"] in
      (* -C to retrieve from cache, no udpatei, bt still quite long, 1,5 sec *)
      (* Return a list of installed packages then available ones:
           Installed Packages
           foo.arch    version   repo
           Available Packages
           bar.arch    version   repo
      *)
      let installed, available, _ =
        List.fold_left (fun (inst,avail,part) l ->
            match l with
            (* beware of locales!! *)
            | "Installed Packages" -> inst, avail, `installed
            | "Available Packages" -> inst, avail, `available
            | _ ->
              (match part, OpamStd.String.split l '.' with
               | `installed, pkg::_ ->
                 OpamSysPkg.Set.add (OpamSysPkg.of_string pkg) inst, avail, part
               | `available, pkg::_ ->
                 inst, OpamSysPkg.Set.add (OpamSysPkg.of_string pkg) avail, part
               | _ -> (* shouldn't happen *) inst, avail, part))
          OpamSysPkg.Set.(empty, empty, `preamble) lines
      in
      let not_found = packages -- installed -- available in
      installed, available, not_found
    | "bsd" ->
      let installed =
        match spv OpamSysPoll.os_distribution with
        | "freebsd" ->
          let installed =
            run_query_command "pkg" ["query"; "%n"]
            |> List.map OpamSysPkg.of_string
            |> OpamSysPkg.Set.of_list
          in
          packages %% installed
        | "openbsd" ->
          let installed =
            run_query_command "pkg_info" ["-mqP"]
            |> List.map OpamSysPkg.of_string
            |> OpamSysPkg.Set.of_list
          in
          packages %% installed
        | _ -> OpamSysPkg.Set.empty
      in
      installed, packages -- installed, OpamSysPkg.Set.empty
    | "debian" ->
      (* First query regular package *)
      let lines =
        (* discard stderr as just nagging *)
        let _, lines =
          run_command ~discard_err:true "dpkg-query"
            ("-l" :: (List.map OpamSysPkg.to_string
                        (OpamSysPkg.Set.elements packages)))
        in
        lines
      in
      let installed =
        List.fold_left
          (fun inst l ->
             match OpamStd.String.split l ' ' with
             | "ii"::pkg::_ ->
               OpamSysPkg.Set.add (OpamSysPkg.of_string pkg) inst
             | _ -> inst)
          OpamSysPkg.Set.empty lines
      in
      let available =
        List.fold_left (fun avail l ->
            match OpamStd.String.split l ' ' with
            | pkg::_
              when OpamSysPkg.Set.mem (OpamSysPkg.of_string pkg) packages ->
              OpamSysPkg.Set.add (OpamSysPkg.of_string pkg) avail
            | _ ->  avail)
          OpamSysPkg.Set.empty
          (run_query_command "apt-cache" ["search"; ".*"])
      in
      let available = available -- installed in
      let not_found = packages -- available -- installed in
      installed, available, not_found
    (* Disable for time saving
          let installed =
            if OpamSysPkg.Set.is_empty not_found then
              installed
            else
            (* If package are not_found look for virtual package. *)
            let resolve_virtual name =
              let lines =
                run_query_command "apt-cache"
                  ["--names-only"; "search"; "^"^name^"$"]
                  (* name need to be escaped, its a regexp *)
              in
              List.fold_left
                (fun acc l -> match OpamStd.String.split l ' ' with
                   | pkg :: _ ->
                   OpamSysPkg.Set.add (OpamSysPkg.of_string pkg) acc
                   | [] -> acc)
                OpamSysPkg.Set.empty lines
            in
            let virtual_map =
              OpamSysPkg.Set.fold (fun vpkg acc ->
                  OpamSysPkg.Set.fold (fun pkg acc ->
                      let old =
                        try OpamSysPkg.Map.find pkg acc
                        with Not_found -> OpamSysPkg.Set.empty
                      in
                      OpamSysPkg.Map.add pkg
                      (OpamSysPkg.Set.add (OpamSysPkg.of_string vpkg) old) acc)
                    (resolve_virtual vpkg)acc)
                not_found OpamSysPkg.Map.empty
            in
            let real_packages =
              List.map fst (OpamSysPkg.Map.bindings virtual_map)
            in
            let dpkg_args pkgs = if pkgs = [] then [] else "-l" :: pkgs in
            let lines = run_query_command "dpkg-query" (dpkg_args real_packages) in
            List.fold_left
              (fun acc l -> match OpamStd.String.split l ' ' with
                 | [pkg;_;_;"installed"] ->
                   (match OpamSysPkg.Map.find_opt pkg virtual_map with
                    | Some p -> p ++ acc
                    | None -> acc)
                 | _ -> acc)
              installed lines
          in
    *)
    | "gentoo" ->
      let sys_installed =
        let re_pkg =
          Re.(compile @@ seq
                [ group @@ rep1 @@ alt [alnum; punct];
                  char '-';
                  rep @@ seq [rep1 digit; char '.'];
                  rep1 digit;
                  rep any;
                  eol ])
        in
        List.fold_left (fun inst dir ->
            let pkg =
              OpamFilename.basename_dir dir
              |> OpamFilename.Base.to_string
            in
            try
              OpamSysPkg.Set.add
                (OpamSysPkg.of_string Re.(Group.get (exec re_pkg pkg) 1))
                inst
            with Not_found -> inst)
          OpamSysPkg.Set.empty
          (OpamFilename.rec_dirs (OpamFilename.Dir.of_string "/var/db/pkg"))
      in
      let installed = packages %% sys_installed in
      let available = packages -- installed in
      installed, available, OpamSysPkg.Set.empty
    | "homebrew" ->
      let lines = run_query_command "brew" ["list"] in
      let installed =
        packages %%
        (List.map (fun s -> OpamStd.String.split s ' ') lines
         |> List.flatten
         |> List.map OpamSysPkg.of_string
         |> OpamSysPkg.Set.of_list)
      in
      installed, packages -- installed, OpamSysPkg.Set.empty
    | "macports" -> OpamSysPkg.Set.(empty,empty,empty) (* Why ? *)
    | "archlinux" | "arch" ->
      let sys_query arg =
        run_query_command "pacman" [arg]
        |> OpamStd.List.filter_map (fun s ->
            match OpamStd.String.split s ' ' with
            | x::_::_ -> Some x
            | _ -> None)
        |> List.map OpamSysPkg.of_string
        |> OpamSysPkg.Set.of_list
      in
      let sys_installed = sys_query "-Qe" in
      let sys_available = sys_query "-Q" in
      let installed = packages %% sys_installed in
      let available = (packages -- installed) %% sys_available in
      let not_found = packages -- installed -- available in
      installed, available, not_found
    | "suse" | "opensuse" ->
      let lines =
        (* get the second column of the table:
           zypper --quiet se -i -t package|grep '^i '|awk -F'|' '{print $2}'|xargs echo*)
        run_query_command "zypper" ["--quiet"; "se"; "-t"; "package"]
      in
      from_system lines
        (fun (inst,avail) l ->
           match OpamStd.String.split l '|' with
           | st::pkg::_ ->
             let pkg = OpamStd.String.strip pkg in
             if OpamStd.String.starts_with ~prefix:"i" st then
               OpamSysPkg.Set.add (OpamSysPkg.of_string pkg) inst, avail
             else
               inst, OpamSysPkg.Set.add (OpamSysPkg.of_string pkg) avail
           | _ -> inst, avail)
    | family ->
      OpamConsole.error_and_exit `Not_found
        "opam doesn't handle system %s for system packages detection.\n \
         Re-run your command with `--ignore-depexts` option to bypass this step."
        family
  in
  available, not_found

(* Install *)

let install_packages_commands s_packages =
  let packages =
    List.map OpamSysPkg.to_string (OpamSysPkg.Set.elements s_packages)
  in
  let y_answer opt r =
    if OpamCoreConfig.(!r.answer) = Some true then
      opt@r
    else r
  in
  match spv OpamSysPoll.os_family with
  | "homebrew" ->
    ["brew"::"install"::packages]
  | "macports" ->
    ["port"::"install"::packages]
  | "debian" ->
    ["apt-get"::"install"::y_answer ["-qq"; "-yy"] packages]
  | "rhel" | "centos" | "fedora" | "mageia" | "oraclelinux" | "ol" ->
    (* todo: check if they all declare "rhel" as primary family *)
    (* When opam-packages specify the epel-release package, usually it
       means that other dependencies require the EPEL repository to be
       already setup when yum-install is called. Cf. opam-depext/#70,#76. *)
    let epel_release = "epel-release" in
    let install_epel =
      if List.mem epel_release packages then
        ["yum"::"install"::y_answer ["-y"] [epel_release]]
      else []
    in
    install_epel @
    ["yum"::"install"::y_answer ["-y"]
       (OpamSysPkg.Set.remove (OpamSysPkg.of_string epel_release) s_packages
        |> OpamSysPkg.Set.elements
        |> List.map OpamSysPkg.to_string);
     "rpm"::"-q"::"--whatprovides"::packages]
  | "bsd" ->
    if spv OpamSysPoll.os_distribution = "freebsd" then
      ["pkg"::"install"::packages]
    else
      ["pkg_add"::packages]
  | "archlinux" | "arch" ->
    ["pacman"::"-S"::"--noconfirm"::packages]
  | "gentoo" ->
    ["emerge"::packages]
  | "alpine" ->
    ["apk"::"add"::packages]
  | "suse" | "opensuse" ->
    ["zypper"::y_answer ["--non-interactive"] ("install"::packages)]
  | family ->
    OpamConsole.error_and_exit `Not_found
      "opam doesn't handle system %s for system packages install commands.\n \
       Re-run your command with `--i-am-not-root` option to bypass this step"
      family

let update_command () =
  match spv OpamSysPoll.os_family with
  | "debian" ->
    Some ["apt-get";"update"]
  | "homebrew" ->
    Some ["brew"; "update"]
  | "rhel" | "centos" | "fedora" | "mageia" | "oraclelinux" | "ol" ->
    Some ["yum"; "makecache"]
  | "archlinux" | "arch" ->
    Some ["pacman"; "-Sy"]
  | "gentoo" ->
    Some ["emerge"; "--sync"]
  | "alpine" ->
    Some ["apk"; "update"]
  | "suse" | "opensuse" ->
    Some ["zypper"; "--non-interactive"; "update"]
  | _ -> None

let sudo_run_command cmd =
  (* Allow it as option ? *)
  let su = OpamSystem.resolve_command "sudo" = None in
  let get_cmd = function
    | c::a -> c, a
    | _  -> assert false
  in
  let cmd, args =
    match spv OpamSysPoll.os, spv OpamSysPoll.os_distribution with
    | "openbsd", _ ->
      if Unix.getuid () <> 0 then (
        "doas", cmd
      ) else get_cmd cmd
    | ("linux" | "unix" | "freebsd" | "netbsd" | "dragonfly"), _
    | "macos", "macports" ->
      if Unix.getuid () <> 0 then (
        if su then
          "su", ["root"; "-c"; Printf.sprintf "%S" (String.concat " " cmd)]
        else
          "sudo", cmd
      ) else get_cmd cmd
    | _ -> get_cmd cmd
  in
  let code = run_command_exit_code cmd args in
  if code <> 0 then Some (cmd,code)
  else None

let update () =
  match update_command () with
  | Some cmd ->
    (match sudo_run_command cmd with
     | Some (cmd, code) ->
       OpamConsole.error_and_exit `False
         "System update failed with exit code %d: %s" code cmd
     | None ->
       OpamConsole.note "System updated succesfully")
  | None ->
    OpamConsole.warning "Unknown system %s, skipping system update"
      (spv OpamSysPoll.os_family)

let install packages =
  if OpamSysPkg.Set.is_empty packages then ()
  else
  let cmds =
    install_packages_commands packages
  in
  let ok =
    List.fold_left (fun ok cmd ->
        match ok with
        | None -> sudo_run_command cmd
        | Some _ as s -> s)
      None cmds
  in
  match ok with
  | Some (cmd, code) ->
    OpamConsole.warning
      "System packages install failed with exit code %d at command:\n  %s"
      code cmd
  | None -> OpamConsole.msg "System packages installed succesfully\n"
