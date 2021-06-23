let print_opamfile header file =
  let content =
    let open OpamParserTypes.FullPos in
    let original = OpamParser.FullPos.file file in
    let rec mangle item =
      match item.pelem with
      | Section s ->
        let section_name =
          match s.section_name with
          | None -> None
          | Some v -> Some {v with pelem = mangle_string v.pelem}
        in
        let section_items =
          {s.section_items with pelem = List.map mangle s.section_items.pelem}
        in
        {item with pelem =
                     Section {s with section_name; section_items}}
      | Variable(name, value) ->
        {item with pelem = Variable(name, mangle_value value)}
    and mangle_value item =
      match item.pelem with
      | String s ->
        {item with pelem = String(mangle_string s)}
      | Relop(op, l, r) ->
        {item with pelem = Relop(op, mangle_value l, mangle_value r)}
      | Prefix_relop(relop, v) ->
        {item with pelem = Prefix_relop(relop, mangle_value v)}
      | Logop(op, l, r) ->
        {item with pelem = Logop(op, mangle_value l, mangle_value r)}
      | Pfxop(op, v) ->
        {item with pelem = Pfxop(op, mangle_value v)}
      | List l ->
        {item with pelem = List{l with pelem = List.map mangle_value l.pelem}}
      | Group l ->
        {item with pelem = Group{l with pelem = List.map mangle_value l.pelem}}
      | Option(v, l) ->
        {item with pelem =
                     Option(mangle_value v,
                            {l with pelem = List.map mangle_value l.pelem})}
      | Env_binding(name, op, v) ->
        {item with pelem = Env_binding(name, op, mangle_value v)}
      | Bool _
      | Int _
      | Ident _ -> item
    and mangle_string = String.map (function '\\' -> '/' | c -> c)
    in
    let mangled =
      {original with file_contents = List.map mangle original.file_contents}
    in
    OpamPrinter.FullPos.Normalise.opamfile mangled
  in
  let str = if header then Printf.sprintf "=> %s <=\n" file else "" in
  let str = Printf.sprintf "%s%s" str content in
  print_string str

let _ =
  match Array.to_list Sys.argv with
  | _::file::[] -> print_opamfile false file
  | _::files -> List.iter (print_opamfile true) files
  | [] -> ()
