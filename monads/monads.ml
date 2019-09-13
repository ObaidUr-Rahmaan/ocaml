module type F = sig
  type _ t

  val map : ('a -> 'b) -> ('a t -> 'b t)
end
(* module type F = sig type _ t val map : ('a -> 'b) -> 'a t -> 'b t end *)

module type M = sig
  include F

  val unit : 'a -> 'a t       

  val mult : ('a t) t -> 'a t
end
(*
module type M =
  sig
    type _ t
    val map : ('a -> 'b) -> 'a t -> 'b t
    val unit : 'a -> 'a t
    val mult : 'a t t -> 'a t
  end
*)

module Monad_laws (Monad : M) = struct
  open Monad

  (* Test monad singnatures *)
  let f  attt = attt |> map mult |> mult
  let f' attt = attt |> mult |> mult

  let g   (at : 'a t) = at |> unit |> mult
  let g'  (at : 'a t) = at |> map unit |> mult
  let g'' (at : 'a t) = at
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

  (* lift2 *)
  let lift2 f at bt ct =
    at >>= fun a ->
    bt >>= fun b ->
    ct >>= fun c ->
    unit (f a b c)

end
(*
module Monad_e :
  functor (Monad : M) ->
    sig
      type 'a t = 'a Monad.t
      val map : ('a -> 'b) -> 'a t -> 'b t
      val unit : 'a -> 'a t
      val mult : 'a t t -> 'a t
      val ( >>= ) : 'a t -> ('a -> 'b t) -> 'b t
      val lift : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
    end
*)

module Option_m : (M with type 'a t = 'a option) = struct
  type 'a t = 'a option

  let map (f : 'a -> 'b) = function
    | None   -> None
    | Some a -> Some (f a)

  let unit a = Some a

  let mult = function
    | None   -> None
    | Some x -> x
end
(*
module Option_m :
  sig
    type 'a t = 'a option
    val map : ('a -> 'b) -> 'a t -> 'b t
    val unit : 'a -> 'a t
    val mult : 'a t t -> 'a t
  end
*)

module Arith = struct
  
  module M = Monad_e (Option_m)
      
  open M

  let (/) x y = match x, y with
    | Some x, Some y -> if y = 0 then None else Some (x/y)
    | _, _ -> None

  (* Arithmetic *)
  let (+) = lift (+)
  let ( * ) = lift ( * )
  let (-) = lift (-)

  (* Arithlogical *)
  let (<) = lift (<)

  (* Logical *)
  let ( && ) = lift ( && )
  let not = map not   

  let x0 = (unit 1) + (unit 2)

  let x1 = x0 - (unit 3)

  let x2 = x0 / x1

  let x3 = x2 * (unit 3)

  let x4 = not (x0 < x1)

  let x5 = x2 < x3
end

(* Same with lists *)
module List_m : (M with type 'a t = 'a list) = struct
  type 'a t = 'a list

  let rec map f = function
    | [] -> []
    | x :: xs -> (f x) :: (map f xs)

  let unit a = [a]

  let mult = List.concat
end

module Id_m : (M with type 'a t = 'a) = struct
  type 'a t = 'a
  let map f = f
  let unit a = a
  let mult a = a
end

module Writer_m : (M with type 'a t = 'a * string) = struct
  type 'a t = 'a * string
  let map f (a, s) = (f a, s)
  let unit a = (a, "")
  let mult ((a, s), s') = (a, s' ^ s)
end

module Logger = struct
  
  module M = Monad_e (Writer_m)
      
  open M

  let (<) (x, s) (y, s') =
    (x < y,
     (if x < y
      then ((string_of_int x) ^ "<"  ^ (string_of_int y) ^ "\n")
      else ((string_of_int x) ^ ">=" ^ (string_of_int y) ^ "\n"))
    ^ s ^ s')
end

module Logged_sort = struct
  open Logger
  open Logger.M
         
  let cons x xs = lift (fun x xs -> x :: xs) x xs

  let rec insert (x : int) = function
    | [] -> unit [x]
    | y :: ys as zs ->
      (unit x) < (unit y) >>= fun b ->
      if b then x :: zs |> unit
      else cons (unit y) (insert x ys)

  let rec sort = function
    | [] -> unit []
    | y :: ys ->
      sort ys >>= fun zs -> 
      insert y zs
end

module Logged_sort' = struct
  let log = ref ""

  let (<) x y =
    log := !log ^ (if x < y
      then ((string_of_int x) ^ "<"  ^ (string_of_int y) ^ "\n")
      else ((string_of_int x) ^ ">=" ^ (string_of_int y) ^ "\n"));
    x < y 
     
  let rec insert x = function
    | [] -> [x]
    | y :: ys as zs ->
      if x < y then x :: zs else y :: insert x ys

  let rec sort = function
    | [] -> []
    | y :: ys -> insert y (sort ys)
end

