module Nat = struct
  type z = Z
  type _ s = S : 'n -> 'n s
end

module PBT = struct
  open Nat

  type ('a, _) btree =
    | Leaf : ('a, z) btree
    | Node : 'a * ('a, 'n) btree * ('a, 'n) btree -> ('a, 'n s) btree

  let rec flip : type n. ('a, n) btree -> ('a, n) btree = function
    | Leaf -> Leaf
    | Node (a, tl, tr) -> Node (a, flip tr, flip tl)

  let rec add : type n. (int, n) btree * (int, n) btree -> (int, n) btree = function
    | Leaf, Leaf -> Leaf
    | Node (a, tl, tr), Node (a', tl', tr') -> Node (a + a', add (tl, tl'), add (tr, tr'))
end