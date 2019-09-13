(* SIMPLE TYPES *)
module Simple_eval = struct
  
type types = Bool | Int 

type value = B of bool | I of int

type expr =
  | Value of value        
  | Plus  of expr * expr (* e + e *)
  | And   of expr * expr (* e & e *)
  | Lt    of expr * expr (* e < e *)
  | Eq    of expr * expr (* e = e *)

let add x y = match x, y with
  | I x, I y -> I (x + y)
  | _, _     -> failwith "add"

let conj (B x) (B y) = B (x && y)

let lt (I x) (I y) = B (x < y)

let eq x y = B (x = y)

let rec eval : expr -> value = function
  | Value v -> v
  | Plus (e, e') -> add  (eval e) (eval e')
  | And  (e, e') -> conj (eval e) (eval e')
  | Lt   (e, e') -> lt   (eval e) (eval e')
  | Eq   (e, e') -> eq   (eval e) (eval e')

let rec check : expr -> types option = function
  | Value (B _)  -> Some Bool
  | Value (I _)  -> Some Int
  | Plus (e, e') ->
    if check e = Some Int  && check e' = Some Int
    then Some Int  else None
  | And  (e, e') ->
    if check e = Some Bool && check e' = Some Bool
    then Some Bool else None
  | Lt   (e, e') ->
    if check e = Some Int  && check e' = Some Int
    then Some Bool else None
  | Eq   (e, e') -> match check e, check e' with
    | Some t, Some t' when t = t' -> Some Bool
    | _, _ -> None

let get_int : value -> int = function
  | I x -> x
  | _ -> failwith "get_int"

let get_bool : value -> bool = function
  | B x -> x
  | _ -> failwith "get_bool"

let e_bad = Plus (Value (B true), Value (B true))

let e = Plus (Value (I 1), Value (I 2))

let n = e |> eval |> get_int
end

(* GADTS *)

module GADT_eval = struct
type 'a value =
  | B : bool -> bool value
  | I : int  -> int  value
      
type 'a expr =
  | Value : 'a value -> 'a expr
  | Plus  : int expr * int expr -> int expr
  | And   : bool expr * bool expr -> bool expr
  | Lt    : int expr * int expr -> bool expr
  | Eq    : 'a expr * 'a expr -> bool expr
      
let e = Plus (Value (I 1), Value (I 2))
    
(*  let e_bad = Plus (Value (B true), Value (B true)) *)
    
let rec eval : type a. a expr -> a = function
  | Value (B b) -> b
  | Value (I n) -> n
  | Plus (e, e') -> (eval e) +  (eval e')
  | And  (e, e') -> (eval e) && (eval e')
  | Lt   (e, e') -> (eval e) <  (eval e')
  | Eq   (e, e') -> (eval e) =  (eval e')
end                           

module To_string = struct
  
  type _ t =
    | Int  : int t
    | Bool : bool t
    | Pair : 'a t * 'b t -> ('a * 'b) t

  let rec to_string : type a. a t -> a -> string =
    fun t x ->
      match t with
      | Int -> string_of_int x
      | Bool -> if x then "tt" else "ff"
      | Pair (t1, t2) ->
        let (x1, x2) = x in
        "( " ^ (to_string t1 x1) ^
        ", " ^ (to_string t2 x2) ^ " )"
        
  let x = to_string (Pair (Int, Bool)) (3, true)
end

module Vector = struct
  
  type z = Z
  type _ s = S : 'n -> 'n s
      
  type ('a, _) vec =
    | Emp : ('a, z) vec
    | Cons : 'a * ('a, 'n) vec -> ('a, 'n s) vec
        
  let n = S(S(S(Z)))
  let v = Cons (1, Cons (0, Emp))
      
  let hd : ('a, 'n s) vec -> 'a = function Cons (a, _) -> a
    
  let tl : ('a, 'n s) vec -> ('a, 'n) vec = function Cons (_, xs) -> xs
end
