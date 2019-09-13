(* Question 1 *)

type void

let f (a : unit) = fun (b : void) -> failwith "f"

(* Enter the right-to-left (from b^0 to 1) iso here *)

let g (p : void -> 'b) = ()

(* Calculate f(g(x)) and g(f(y)) showing that they equal the identity. 

Case 1. () |> f |> g = (fun b -> failwith "f") |> g = ()

Case 2. p |> g |> f = () |> f = fun b -> failwith "f"

We need to show that all functions of type void -> 'b are equal i.e. 

forall p q : void -> 'b
forall x : void
p x = q x

This is trivial by quantification over the empty set.

*)


(* Question 2 *)

type ('a, 'b, 'c) sum3 = A of 'a | B of 'b | C of 'c

type 'a t = bool -> ('a option)

type 'a t' = (bool -> 'a, bool * 'a, unit) sum3

let (f : 'a t -> 'a t') = fun p -> 
  match p true, p false with
  | Some a, Some a' -> A (fun b -> if b then a else a')
  | Some a, None    -> B (true, a)
  | None,   Some a' -> B (false, a')
  | None,   None    -> C ()

let (g : 'a t' -> 'a t) = function
  | A f          -> fun b -> Some (f b)
  | B (true,  a) -> fun b -> if b then Some a else None
  | B (false, a) -> fun b -> if b then None else Some a
  | C ()         -> fun b -> None

(*
# let f = function (a, Left b) -> Left (a, b) | (a, Right c) -> Right (a, c);;
val f : 'a * ('b, 'c) sum -> ('a * 'b, 'a * 'c) sum = <fun>

# let g = function Left (a, b) -> (a, Left b) | Right (a, c) -> (a, Right c);;
val g : ('a * 'b, 'a * 'c) sum -> 'a * ('b, 'c) sum = <fun>

1) Need to show 

x |> f |> g = x

For f we need to consider two cases:

a) x = (a, Left b)

(a, Left b) |> f |> g = Left (a, b) |> g = (a, Left b)

b) x = (a, Right c)

(a, Right c) |> f |> g = Right (a, c) |> g = (a, Right c)

The other direction is similar.

*)
