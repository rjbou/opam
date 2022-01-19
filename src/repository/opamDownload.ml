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

open OpamTypes
open OpamProcess.Job.Op

let log fmt = OpamConsole.log "CURL" fmt

exception Download_fail of string option * string
let fail (s,l) = raise (Download_fail (s,l))

let user_agent =
  CString (Printf.sprintf "opam/%s" (OpamVersion.(to_string current)))

let curl_args = [
  CString "--write-out", None;
  CString "%%{http_code}\\n", None;
  CString "--retry", None; CIdent "retry", None;
  CString "--retry-delay", None; CString "2", None;
  CString "--compressed",
  Some (FIdent (OpamFilter.ident_of_string "compress"));
  CString "--user-agent", None; user_agent, None;
  CString "-L", None;
  CString "-o", None; CIdent "out", None;
  CString "--", None; (* End list of options *)
  CIdent "url", None;
]

let wget_args = [
  CString "--content-disposition", None;
  CString "-t", None; CIdent "retry", None;
  CString "-O", None; CIdent "out", None;
  CString "-U", None; user_agent, None;
  CString "--", None; (* End list of options *)
  CIdent "url", None;
]

let fetch_args = [
  CString "-o", None; CIdent "out", None;
  CString "--user-agent", None; user_agent, None;
  CString "--", None; (* End list of options *)
  CIdent "url", None;
]

let ftp_args = [
  CString "-o", None; CIdent "out", None;
  CString "-U", None; user_agent, None;
  CString "--", None; (* End list of options *)
  CIdent "url", None;
]

let download_args ~url ~out ~retry ?checksum ~compress () =
  let cmd, _ = Lazy.force OpamRepositoryConfig.(!r.download_tool) in
  let cmd =
    match cmd with
    | [(CIdent "wget"), _] -> cmd @ wget_args
    | [(CIdent "fetch"), _] -> cmd @ fetch_args
    | [(CIdent "ftp"), _] -> cmd @ ftp_args
    | [_] -> cmd @ curl_args (* Assume curl if the command is a single arg *)
    | _ -> cmd
  in
  OpamFilter.single_command (fun v ->
      if not (OpamVariable.Full.is_global v) then None else
      match OpamVariable.to_string (OpamVariable.Full.variable v) with
      | ("curl" | "wget" | "fetch" | "ftp") as dl_tool-> Some (S dl_tool)
      | "url" -> Some (S (OpamUrl.to_string url))
      | "out" -> Some (S out)
      | "retry" -> Some (S (string_of_int retry))
      | "compress" -> Some (B compress)
      | "opam-version" -> Some (S OpamVersion.(to_string current))
      | "checksum" ->
        OpamStd.Option.map (fun c -> S OpamHash.(to_string c)) checksum
      | "hashalgo" ->
        OpamStd.Option.map (fun c -> S OpamHash.(string_of_kind (kind c)))
          checksum
      | "hashpath" ->
        OpamStd.Option.map
          (fun c -> S (String.concat Filename.dir_sep OpamHash.(to_path c)))
          checksum
      | "hashvalue" ->
        OpamStd.Option.map (fun c -> S OpamHash.(contents c)) checksum
      | _ -> None)
    cmd

let tool_return url ret =
  match Lazy.force OpamRepositoryConfig.(!r.download_tool) with
  | _, `Default ->
    if OpamProcess.is_failure ret then
      fail (Some "Download command failed",
                Printf.sprintf "Download command failed: %s"
                  (OpamProcess.result_summary ret))
    else Done ()
  | _, `Curl ->
    if OpamProcess.is_failure ret then
      fail (Some "Curl failed", Printf.sprintf "Curl failed: %s"
                  (OpamProcess.result_summary ret));
    match ret.OpamProcess.r_stdout with
    | [] ->
      fail (Some "curl empty response",
                Printf.sprintf "curl: empty response while downloading %s"
                  (OpamUrl.to_string url))
    | l  ->
      let code = List.hd (List.rev l) in
      let num = try int_of_string code with Failure _ -> 999 in
      if num >= 400 then
        fail (Some ("curl error code " ^ code),
                  Printf.sprintf "curl: code %s while downloading %s"
                    code (OpamUrl.to_string url))
      else Done ()

let download_command ~compress ?checksum ~url ~dst () =
  let cmd, args =
    match
      download_args
        ~url
        ~out:dst
        ~retry:OpamRepositoryConfig.(!r.retries)
        ?checksum
        ~compress
        ()
    with
    | cmd::args -> cmd, args
    | [] ->
      OpamConsole.error_and_exit `Configuration_error
        "Empty custom download command"
  in
  OpamSystem.make_command ~allow_stdin:false cmd args @@> tool_return url

let really_download
    ?(quiet=false) ~overwrite ?(compress=false) ?checksum ?(validate=true)
    ~url ~dst () =
  assert (url.OpamUrl.backend = `http);
  let tmp_dst = dst ^ ".part" in
  if Sys.file_exists tmp_dst then OpamSystem.remove tmp_dst;
  OpamProcess.Job.catch
    (function
      | Failure s as e ->
        OpamSystem.remove tmp_dst;
        if not quiet then OpamConsole.error "%s" s;
        raise e
      | e ->
        OpamSystem.remove tmp_dst;
        OpamStd.Exn.fatal e;
        log "Could not download file at %s." (OpamUrl.to_string url);
        raise e)
  @@ fun () ->
  download_command ~compress ?checksum ~url ~dst:tmp_dst ()
  @@+ fun () ->
  if not (Sys.file_exists tmp_dst) then
    fail (Some "Downloaded file not found",
          "Download command succeeded, but resulting file not found")
  else if Sys.file_exists dst && not overwrite then
    OpamSystem.internal_error "The downloaded file will overwrite %s." dst;
  if validate &&
     OpamRepositoryConfig.(!r.force_checksums <> Some false) then
    OpamStd.Option.iter (fun cksum ->
        if not (OpamHash.check_file tmp_dst cksum) then
          fail (Some "Bad checksum",
                    Printf.sprintf "Bad checksum, expected %s"
                      (OpamHash.to_string cksum)))
      checksum;
  OpamSystem.mv tmp_dst dst;
  Done ()

let download_as ?quiet ?validate ~overwrite ?compress ?checksum url dst =
  match OpamUrl.local_file url with
  | Some src ->
    if src = dst then Done () else
      (if OpamFilename.exists dst then
         if overwrite then OpamFilename.remove dst else
           OpamSystem.internal_error "The downloaded file will overwrite %s."
             (OpamFilename.to_string dst);
       OpamFilename.copy ~src ~dst;
       Done ())
  | None ->
    OpamFilename.(mkdir (dirname dst));
    really_download ?quiet ~overwrite ?compress ?checksum ?validate
      ~url
      ~dst:(OpamFilename.to_string dst)
      ()

let download ?quiet ?validate ~overwrite ?compress ?checksum url dstdir =
  let dst =
    OpamFilename.(create dstdir (Base.of_string (OpamUrl.basename url)))
  in
  download_as ?quiet ?validate ~overwrite ?compress ?checksum url dst @@|
  fun () -> dst

let get_output ~post ?(args=[]) url =
  let cmd, _ = Lazy.force OpamRepositoryConfig.(!r.download_tool) in
    let cmd =
      match cmd with
      | [(CIdent ("wget"|"fetch"|"curl" as cmd)), _] -> cmd
      | _ -> "curl"
    in
  let args =
    if post then
      let post =
        match cmd with
        | "wget" -> [] (* TODO check *)
        | "fetch" -> [] (* TODO check *)
        | "curl" -> ["-X"; "POST"]
        | _ -> assert false
      in
      post @ args
    else args
  in
  (* XXX use read command output ? *)
  OpamFilename.with_tmp_dir_job @@ fun dir ->
  let stdout = OpamFilename.Op.(dir // "get_output_stdout") in
  OpamFilename.touch stdout;
  OpamSystem.make_command ~stdout:(OpamFilename.to_string stdout) cmd
    (args @ [OpamUrl.to_string url]) @@> function
    { OpamProcess.r_code; OpamProcess.r_stdout; _ } ->
    if r_code <> 0 then Done None else Done (Some r_stdout)


module SWHID = struct

  (** SWHID retrieval functions *)

  let log fmt = OpamConsole.log "CURL(SWHID)" fmt

  let instance = OpamUrl.of_string "https://archive.softwareheritage.org"
  (* we keep api 1 hardcoded for the moment *)
  let full_url middle hash = OpamUrl.Op.(instance / "api" / "1" / middle / hash / "")

  let get_value key s =
    match OpamJson.of_string s with
    | Some (`O elems) ->
      (match OpamStd.List.assoc_opt key elems with
       | Some (`String v) -> Some v
       | _ -> None)
    | _ -> None

  (* SWH request output example
     directory: retrieve "status" & "fetch_url"
     $ curl https://archive.softwareheritage.org/api/1/vault/directory/4453cfbdab1a996658cd1a815711664ee7742380/
     {
      "fetch_url": "https://archive.softwareheritage.org/api/1/vault/flat/swh:1:dir:4453cfbdab1a996658cd1a815711664ee7742380/raw/",
      "progress_message": null,
      "id": 398307347,
      "status": "done",
      "swhid": "swh:1:dir:4453cfbdab1a996658cd1a815711664ee7742380",
      "obj_type": "directory",
      "obj_id": "4453cfbdab1a996658cd1a815711664ee7742380"
     }
  *)

  let get_output ?(post=false) url =
    get_output ~post url @@| OpamStd.Option.replace @@ fun out ->
    Some (String.concat "" out)

  let get_dir hash =
    let url = full_url "vault/directory" hash in
    get_output ~post:true url @@| OpamStd.Option.replace @@ fun json ->
    let status = get_value "status" json in
    let fetch_url = get_value "fetch_url" json in
    match status, fetch_url with
    | None, _ | _, None -> None
    | Some status, Some fetch_url ->
      Some (match status with
          | "done" -> `Done (OpamUrl.of_string fetch_url)
          | "pending" -> `Pending
          | "new" -> `New
          | "failed" -> `Failed
          | _ -> `Unknown)

  let fallback_err fmt = Printf.sprintf ("SWH fallback: "^^fmt)

  let get_url ?(timeout=6) swhid =
    let attempts = timeout in
    let hash = OpamSWHID.hash swhid in
    let rec aux timeout =
      if timeout <= 0 then
        Done (Not_available
                (Some (fallback_err "timeout"),
                 fallback_err "%d attempts tried, aborting" attempts))
      else
        get_dir hash @@+ function
        | Some (`Done fetch_url) -> Done (Result fetch_url)
        | Some (`Pending | `New) ->
          Unix.sleep 10;
          aux (timeout - 1)
        | None | Some (`Failed | `Unknown) ->
          Done (Not_available (None, fallback_err "Unknown swhid"))
    in
    aux timeout

  (* for the moment only used in sources, not extra sources or files *)
  let archive_fallback ?timeout urlf dirnames =
    match OpamFile.URL.swhid urlf with
    | None -> Done (Result None)
    | Some swhid ->
      (* Add a global modifier and/or command for default answering *)
      if OpamConsole.confirm ~default:false
          "Source %s is not available. Do you want to try to retrieve it \
           from Software Heritage cache? It may take few minutes."
          (OpamConsole.colorise `underline
             (OpamUrl.to_string (OpamFile.URL.url urlf))) then
        (log "SWH fallback for %s" (OpamUrl.to_string (OpamFile.URL.url urlf));
         get_url ?timeout swhid @@+ function
         | Not_available _ as error -> Done error
         | Up_to_date _ -> assert false
         | Result url ->
           let hash = OpamSWHID.hash swhid in
           OpamFilename.with_tmp_dir_job @@ fun dir ->
           let archive =  OpamFilename.Op.(dir // hash) in
           download_as ~overwrite:true url archive @@+ fun () ->
           let sources = OpamFilename.Op.(dir / "src") in
           OpamFilename.extract_job archive sources @@| function
           | Some e ->
             Not_available (
               Some (fallback_err "archive extraction failure"),
               fallback_err "archive extraction failure %s"
                 (match e with
                  | Failure s -> s
                  | OpamSystem.Process_error pe ->
                    OpamProcess.string_of_result pe
                  | e -> Printexc.to_string e))
           | None ->
             (match OpamSWHID.compute sources with
              | None ->
                Not_available (
                  Some (fallback_err "can't check archive validity"),
                  fallback_err
                    "error on swhid computation, can't check its validity")
              | Some computed ->
                if String.equal computed hash then
                  (List.iter (fun (_nv, dst, _sp) ->
                       (* add a text *)
                       OpamFilename.copy_dir ~src:sources ~dst)
                      dirnames;
                   Result (Some "SWH fallback"))
                else
                  Not_available (
                    Some (fallback_err "archive not valid"),
                    fallback_err
                      "archive corrupted, opam file swhid %S vs computed %S"
                      hash computed)))
      else
        Done (Not_available
                (Some (fallback_err "no retrieval"),
                 fallback_err "retrieval refused by user"))

end
