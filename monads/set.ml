
module type M = sig
  type _ t
 
   val map : ('a -> 'b) -> ('a t -> 'b t)
   
   val unit : 'a -> 'a t       
 
   val mult : ('a t) t -> 'a t
 end
 
 module Monad_e (Monad : M) = struct
   include Monad 
 
   (* bind *)
   let ( >>= ) : 'a t -> ('a -> 'b t) -> 'b t =
     fun at f -> at |> (map f) |> mult
 
   (* lift *)
   let lift f at bt =
     at >>= fun a ->
     bt >>= fun b ->
     unit (f a b)
 end
 
module type SET = sig
  type 'a t
  val empty     : 'a t
  val singleton : 'a -> 'a t
  val intersect : 'a t -> 'a t -> 'a t
  val union     : 'a t -> 'a t -> 'a t
  val member    : 'a -> 'a t -> bool
  val map       : ('a -> 'b) -> ('a t -> 'b t)
  val fold      : ('a -> 'b -> 'a) -> 'a -> 'b t -> 'a
  val eq        : 'a t -> 'a t -> bool
end
 
 (* Question 1 *)
module Set : SET = struct
  type 'a t = 'a list

  let empty = []

  let singleton x = [x]

  let rec member x = function
    | [] -> false
    | y::ys when x = y -> true
    | _::ys -> member x ys

  let rec intersect s1 = function
    | [] -> []
    | x::xs when (member x s1) ->  x::(intersect s1 xs)
    | _::xs -> intersect s1 xs

  let rec union s1 = function
    | [] -> s1
    | x::xs when (member x s1) -> union s1 xs
    | x::xs -> x::(union s1 xs)

  let rec fold f a = function
    | [] -> a
    | x::xs -> f (fold f a xs) x

  let is_subset s2 s1 = fold (fun a c -> a && (member c s1)) true s2

  let eq s1 s2 = (is_subset s1 s2) && (is_subset s2 s1)

  let map f = fold (fun a c -> (f c)::a ) empty
end
 
module type SM = sig
  include M
  include SET with type 'a t := 'a t
end
 
(* Question 3 *)
module Set_m : (SM with type 'a t = 'a Set.t) = struct
  include Set

  let unit a = singleton a

  let mult = function
    | x when x = empty -> empty
    | x -> (fold (fun acc curr -> union curr acc) empty x)
end
 
(* Question 4 *)
module N = struct
  open Set_m
  include Monad_e (Set_m)

  let ( % ) = lift ( mod )
  let ( - ) = lift ( - )
  let ( <= ) = lift ( <= )
  let ( / ) = lift ( / )

  let modulo x s = map (fun y -> x % (unit y)) s |> mult

  (* Generates a set of numbers from 2 to x *)
  let rec get_numbers = function
    | x when x = empty -> empty
    | x when x <= unit(1) = unit(true) -> empty
    | x when x = unit(2) -> unit(2)
    | x -> union x (get_numbers (x - (unit 1)))

  let is_prime n = 
    if n = 0 then false else
      let n = unit (n) in
      let numbers = get_numbers ( n / (unit 2) ) in
        modulo n numbers |> member 0 |> not
end

module Test = struct
  open N

  let _ =  
      assert (is_prime 7);
      assert (not (is_prime 6));
      print_endline "1"
end
