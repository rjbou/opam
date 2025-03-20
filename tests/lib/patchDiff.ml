(* layout:
   - first
     - same-file
     - diff-file
     - diff-file-plus-fst
     - diff-file-plus-snd
     - file-only-fst
     - same-dir
     - diff-dir-plus-fst
     - diff-dir-plus-snd
     - dir-only-fst
     - file-fst-dir-snd
     - dir-fst-file-snd
   - second
     - same-file
     - diff-file
     - diff-file-plus-fst
     - diff-file-plus-snd
     - file-only-fst
     - same-dir
     - diff-dir-plus-fst
     - diff-dir-plus-snd
     - dir-only-fst
     - file-fst-dir-snd
     - dir-fst-file-snd
*)

type content =
  | F of string (* file *)
  | D of (string * string) list (* directory with list filename * content *)
  | V (* void *)

type arborescence = {
  name: string;
  first : content;
  second : content;
}

let content =
  let foo = "foo\n" in
  let foobar = "foo\nbar\n" in
  let bar = "bar\n" in
  [
    { name = "same-file";
      first = F foo;
      second = F foo;
    };
    { name = "diff-file";
      first = F foo;
      second = F bar;
    };
    { name = "diff-file-plus-fst";
      first = F foobar;
      second = F foo;
    };
    { name = "diff-file-plus-snd";
      first = F foo;
      second = F foobar;
    };
    { name = "file-only-fst";
      first = F foo;
      second = V;
    };
    { name = "file-only-snd";
      first = V;
      second = F foo;
    };
    { name = "same-dir";
      first = D [];
      second = D [];
    };
    { name = "diff-dir-plus-fst";
      first = D [ "fst", foo ];
      second = D [ "fst", foobar ] ;
    };
    { name = "diff-dir-plus-snd";
      first = D [ "fst", foobar ];
      second = D [ "fst", foo ];
    };
    { name = "dir-only-fst";
      first = D [ "fst", foo ];
      second = V;
    };
    { name = "file-fst-dir-snd";
      first = F foo;
      second = D [ "fst", foo];
    };
    { name = "dir-fst-file-snd";
      first = D [ "fst", foo ];
      second = F foo;
    };
  ]

let print = Printf.eprintf
let read_dir dir =
  let lst =
    List.map (OpamFilename.remove_prefix dir) (OpamFilename.rec_files dir)
    @
    List.map (OpamFilename.remove_prefix_dir dir) (OpamFilename.rec_dirs dir)
  in
  OpamStd.Format.itemize ~bullet:"+ "
    Fun.id (List.sort String.compare lst)

let first = "first"
let second = "second"
let write_setup dir =
  let open OpamFilename.Op in
  let first_root = dir / first in
  let second_root = dir / second in
  OpamFilename.mkdir first_root;
  OpamFilename.mkdir second_root;
  let create dir name = function
    | F content ->
      OpamFilename.write (dir // name) content
    | D lst ->
      let dir = dir / name in
      List.iter (fun (n,c) -> OpamFilename.write (dir // n) c) lst
    | V -> ()
  in
  List.iter (fun {name; first; second} ->
      create first_root name first;
      create second_root name second)
    content


let _ =
  let open OpamProcess.Job.Op in
  OpamProcess.Job.run @@
  ((OpamFilename.with_tmp_dir_job @@ fun dir ->
    write_setup dir;
    print "*** SETUP ***\n";
    print "%s\n" (read_dir dir);
    OpamRepositoryBackend.get_diff dir
      (OpamFilename.Base.of_string first)
      (OpamFilename.Base.of_string second)
    @@+ fun diff ->
    match diff with
    | None -> Done (print "No diff")
    | Some diff ->
      print "*** DIFF ***\n";
      print "%s\n" (OpamFilename.read diff);
      OpamFilename.patch ~allow_unclean:false diff
        OpamFilename.Op.(dir / first)
      @@| fun result ->
      match result with
      | None ->
        print "*** PATCH ***\n";
        print "%s\n" (read_dir dir)
      | Some exn ->
        print "*** PATCH ERROR ***\n";
        print "=> %s\n" (Printexc.to_string exn)
   ));
  Done ()

(* TODO add test for S_LNK, S_CHR, S_BLK, S_FIFO, S_SOCK *)
(* TODO add faulty patch test *)
