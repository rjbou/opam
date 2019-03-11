
val get_installed_packages: OpamStd.String.Set.t -> OpamStd.String.Set.t
val update : su:bool -> interactive:bool -> unit
val install: su:bool -> interactive:bool -> OpamStd.String.Set.t -> unit
