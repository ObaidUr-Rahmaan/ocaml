(*

Counts the number of elements occurring in duplicates. If an element occurs more than twice then each occurrence counts.

*)

let count_dup xs =
  let rec aux xs = match xs with
   | [] -> 0
   | x :: y :: xs when x = y -> (aux (y :: xs)) + 1
   | x :: xs -> aux xs
  in List.sort compare xs |> aux
  
  
