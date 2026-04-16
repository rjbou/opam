(**************************************************************************)
(*                                                                        *)
(*    Copyright 2025 Kate Deplaix                                         *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

(* TAR TODOC : documentation *)
(* TAR TODO : change fname to tar when accurate *)

open Tar.Syntax
open OpamTypes

let tdebug go =
  if go then
    fun fmt ->
      Printf.ksprintf (fun str ->  OpamConsole.error "TAR:%s" str) fmt
  else
    fun fmt ->
      Printf.ksprintf (fun _ -> ()) fmt

type tar = filename

type tar_file = OpamFilename.Raw.t
type tar_content = string

let rec safe_read fd buf off len =
  try Unix.read fd buf off len
  with Unix.Unix_error (Unix.EINTR, _, _) -> safe_read fd buf off len

let rec run : type a. Unix.file_descr -> (a, _, _) Tar.t -> a = fun fd -> function
  | Tar.Read len ->
    let b = Bytes.create len in
    let read = safe_read fd b 0 len in
    if read = 0 then
      failwith "unexpected end of file"
    else if len = (read : int) then
      Bytes.unsafe_to_string b
    else
      Bytes.sub_string b 0 read
  | Tar.Really_read len ->
    let rec loop fd buf offset len =
      if offset < (len : int) then
        let n = safe_read fd buf offset (len - offset) in
        if n = 0 then
          failwith "unexpected end of file"
        else
          loop fd buf (offset + n) len
    in
    let buf = Bytes.create len in
    loop fd buf 0 len;
    Bytes.unsafe_to_string buf
  | Tar.Return (Ok x) -> x
  | Tar.Return (Error _) -> failwith "something's gone wrong"
  | Tar.High _ | Tar.Write _ | Tar.Seek _ -> assert false
  | Tar.Bind (x, f) -> run fd (f (run fd x))

let fold_reg_files_aux f acc fd =
  let go ?global:_ hdr acc =
    match hdr.Tar.Header.link_indicator with
    | Normal ->
      let* content = Tar.really_read (Int64.to_int hdr.file_size) in
      let acc = f acc (OpamFilename.Raw.of_string hdr.file_name) content in
      Tar.return (Ok acc)
    | Directory -> Tar.return (Ok acc)
    | Hard -> failwith "hardlinks unsupported"
    | Symbolic -> failwith "symlinks unsupported"
    | Character -> failwith "char devices unsupported"
    | Block -> failwith "block devices unsupported"
    | FIFO -> failwith "fifo unsupported"
    | GlobalExtendedHeader -> failwith "global extended header unsupported"
    | PerFileExtendedHeader -> failwith "perfile extended header unsupported"
    | LongLink -> failwith "longlinks unsupported"
    | LongName -> failwith "longnames unsupported"
  in
  run fd (Tar_gz.in_gzipped (Tar.fold go acc))

let fold_reg_files f acc fname =
  let fd = Unix.openfile (OpamFilename.to_string fname) [Unix.O_RDONLY] 0 in
  Fun.protect ~finally:(fun () -> Unix.close fd) @@ fun () ->
  fold_reg_files_aux f acc fd

module Inplace = struct
  module Map = OpamFilename.Raw.Map
  type t = Unix.file_descr * tar_content Map.t

  let tdebug = tdebug false

  let with_open_out fname f =
    let fd = Unix.openfile (OpamFilename.to_string fname) [Unix.O_RDWR] 0o640 in
    Fun.protect ~finally:(fun () -> Unix.close fd) @@ fun () ->
    f (fd, fold_reg_files_aux (fun acc k x -> Map.add k x acc) Map.empty fd)

  let fold_reg_files f acc (_fd, t) =
    Map.fold (fun k x acc -> f acc k x) t acc

  let exists ~fname (_, t) =
    tdebug "exists: %s" (OpamFilename.Raw.to_string fname);
    Map.mem fname t

  let read ~fname (_, t) =
    tdebug "read: %s" (OpamFilename.Raw.to_string fname);
    Map.find fname t

  let add ~fname ~content (fd, t) =
    tdebug "add: %s" (OpamFilename.Raw.to_string fname);
    (fd, Map.add fname content t)

  let mv ~src ~dst ((fd,t) as tar) =
    tdebug "%s" @@ Printf.sprintf "mv: %s -> %s"
    (OpamFilename.Raw.to_string src) (OpamFilename.Raw.to_string dst);
    let content = read ~fname:src tar in
    let t =
      Map.remove src t
      |> Map.add dst content
    in
    (fd, t)

  let remove ~fname (fd, t) =
    tdebug "rm: %s" (OpamFilename.Raw.to_string fname);
    (fd, Map.remove fname t)

  let remove_dir ~dname (fd, t) =
    tdebug "rmdir: %s" (OpamFilename.Raw.Dir.to_string dname);
    let t =
      Map.filter (fun fname _ ->
          not (OpamFilename.Raw.starts_with dname fname)) t
    in
    (fd, t)

  let write (fd, t) =
    let to_buffer (buf:Buffer.t) t =
      let rec run : type a. Buffer.t -> (a, 'err, _) Tar.t -> a = fun buf -> function
        | Tar.Write str ->
          Buffer.add_string buf str
        | Tar.Read _ | Tar.Really_read _ | Tar.Seek _ | Tar.High _ ->
          assert false
        | Tar.Return (Ok value) ->
          value
        | Tar.Return (Error _) ->
          failwith "something went wrong"
        | Tar.Bind (x, f) ->
          run buf (f (run buf x))
      in
      run buf t
    in
    let entries =
      let dispenser =
        Map.fold (fun path content acc ->
            let path = OpamFilename.Raw.to_string path in
            let hdr =
              Tar.Header.make ~file_mode:0o640 ~mod_time:0L ~user_id:0 ~group_id:0
                path (Int64.of_int (String.length content))
            in
            (*             let data = fun () -> Tar.return (Ok (Some content)) in *)
            let data =
              let closed = ref false in
              fun () -> match !closed with
                | false -> closed := true; Tar.return (Ok (Some content))
                | true -> Tar.return (Ok None) in
            let entry = (Some Tar.Header.Ustar, hdr, data) in
            OpamCompat.Seq.cons entry acc)
          t Seq.empty
        |> OpamCompat.Seq.to_dispenser
      in
      fun () ->
        match dispenser () with
        | None -> Tar.return (Ok None)
        | Some x -> Tar.return (Ok (Some x))
    in
    let t = Tar.out ~level:Ustar entries in
    let t = Tar_gz.out_gzipped ~level:4 ~mtime:0l Gz.Unix t in
    let buf = Buffer.create 10_485_760 in
    to_buffer buf t;
    let str = Buffer.contents buf in
    let _ : int = Unix.lseek fd 0 Unix.SEEK_SET in
    Unix.ftruncate fd 0;
    let _ : int = Unix.write_substring fd str 0 (String.length str) in
    ()
end

module PatchConf = struct
  type root = OpamFilename.t
  module Tar = Inplace
  type file = OpamFilename.Raw.t
  type target = Tar.t
  let label = "archive"
  let translate_patch = false
  let root_to_string = OpamFilename.to_string
  let file_to_string = OpamFilename.Raw.to_string
  let end_slash = Fun.id
  let get_path _fail _target =
    (* TAR TODO check escapability ? *)
    OpamFilename.Raw.of_string
  let ext file ext = OpamFilename.Raw.add_extension file ext
  let write file content target = Tar.add ~fname:file ~content target
  let exists file = Tar.exists ~fname:file
  let exists_dir _file _target = false
  let read file = Tar.read ~fname:file
  let remove file = Tar.remove ~fname:file
  let remove_dir file target =
    Tar.remove_dir ~dname:(OpamFilename.Raw.dirname file) target
  let same_dirname ~src ~dst =
    OpamFilename.Raw.dirname src
    <> (OpamFilename.Raw.dirname dst : OpamFilename.Raw.Dir.t)
  let mv = Tar.mv
  let open_ = Tar.with_open_out
  let save = Tar.write
end

let patch ~allow_unclean patch_source tar =
  OpamPatch.patch (module PatchConf) ~allow_unclean patch_source tar
