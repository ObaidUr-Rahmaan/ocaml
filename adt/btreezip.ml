type 'a btree = Leaf of 'a | Node of ('a btree * 'a btree)

type direction = Left | Right

type 'a bzipper = (direction * 'a btree) list

module BZipper = struct
let rec bzipper_first = function
  | Leaf a -> a, []
  | Node (tl, tr) ->
    let a, z = bzipper_first tl in 
    a, z @ [Right, tr]

(* Recover the last position in a zipper *)
let rec bzipper_last = function
  | Leaf a -> a, []
  | Node (tl, tr) ->
    let a, z = bzipper_last tr in
    a, z @ [Left, tl]

(* To go next left look in the zipper:
   - if you are on a 'left' branch go up and reconstruct the tree as you go up
   - if you are on a 'right' branch put the current reconstructed tree in the zipper then 
     - take the next left down
     - then go the the rightmost branch while reconstructing the zipper
*)
let rec bzipper_left t = function
  | [] -> failwith "bzipper_left"
  | (Right, tr) :: z -> bzipper_left (Node (t, tr)) z
  | (Left,  tl) :: z ->
    let a, z' = bzipper_last tl in 
    a, z' @ (Right, t) :: z

(* To go next right look in the zipper:
   - if you are on a 'right' branch go up and reconstruct the tree as you go up
   - if you are on a 'left' branch put the current reconstructed tree in the zipper then 
     - take the next right down
     - then go the the leftmost branch while reconstructing the zipper
*)
let rec bzipper_right t = function
  | [] -> failwith "bzipper_right"
  | (Left,  tl) :: z -> bzipper_right (Node (t, tl)) z
  | (Right, tr) :: z ->
    let a, z' = bzipper_first tr in 
    a, z' @ (Left, t) :: z

let rec btree_of_bzipper t = function
  | [] -> t
  | (Left,  tl) :: z -> btree_of_bzipper (Node (tl, t)) z
  | (Right, tr) :: z -> btree_of_bzipper (Node (t, tr)) z
end                         

(* Some simple tests *) 
let l n = Leaf n

let t0 = Node (l 0, l 1)

let t1 = Node (l 2, l 3)

let t2 = Node (t0, t1)

let t3 = Node (l 4, l 5)

let t4 = Node (t2, t3)

let (a, z) = BZipper.bzipper_first t4

let (a', z') = BZipper.bzipper_last t4

let (a, z) = BZipper.bzipper_right (Leaf a) z

let (a', z') = BZipper.bzipper_left (Leaf a') z'
