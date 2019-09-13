module type DBLCIRCULAR = sig
  
  exception Empty
  type 'a circular
  
  val create : 'a -> 'a circular
  val empty : 'a circular -> bool
  val peek : 'a circular -> 'a
  val ins : 'a -> 'a circular -> unit
  val del : 'a circular -> unit
  val fwd : 'a circular -> unit
  val rev : 'a circular -> unit
  val fold: 'a circular -> 'b -> ('b -> 'a -> 'b) -> 'b

end