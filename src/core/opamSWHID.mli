(* Software Heritage Identifiers *)
type t = {
  swh_sch_version: int;
  swh_object_type: [`rev | `rel];
  swh_hash: string
}
include OpamStd.ABSTRACT with type t := t
(*   val is_valid : string -> bool *)

