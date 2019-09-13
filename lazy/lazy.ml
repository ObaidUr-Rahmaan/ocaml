type 'a cell   = Cons of 'a * 'a stream
and  'a stream = ('a cell) Lazy.t;;

let peek = function
  | lazy (Cons (x, _)) -> x;;

let next = function
  | lazy (Cons (_, xs)) -> xs;;

let rec map f = function 
  | lazy (Cons (x, xs)) -> lazy (Cons (f x, map f xs));;

let rec fold f x0 = function
  | lazy (Cons (x, xs)) ->
    let x1 = f x0 x in 
    lazy (Cons (x1, fold f x1 xs));;

let rec from_const k = lazy (Cons (k, from_const k));;

(* Q1 : Map over two streams *)

let rec map2 f s s' = match s, s' with
  | lazy (Cons (x, xs)), lazy (Cons (x', xs')) ->
    lazy (Cons (f x x', map2 f xs xs'));;

let rec sum s s' = map2 (+) s s';;

(* Q2 : Differential *)

let dif s = map2 (-) (next s) s;;

(* Q3 : Running average of k *)

let rec kSum k s =
  if k = 0 then from_const 0 
  else map2 (+) s (kSum (k-1) (next s));;

let rec avg k s = map (fun x -> x / k) (kSum k s);;