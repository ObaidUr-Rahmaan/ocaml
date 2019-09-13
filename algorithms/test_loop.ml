
(*

Tests if a directed graph given as input has at least one loop, i.e. a sequence of consecutive edges which reaches 
back to its starting point. The graph is given as a list of edges, represented as pairs of nodes. For example one 
of the representations a graph could be the list [(1,2); (1,3); (3,2); (3,4); (4;3)]. This graph has one loop, 3 -> 4 -> 3.

*)


let rec get_next x xys = List.filter (fun (x', y') -> x' = x) xys |> List.map snd

let rec rem_dups = function
  | [] -> []
  | [x] -> [x]
  | x :: x' :: xs when x <> x' -> x :: rem_dups (x' :: xs)
  | _ :: xs -> rem_dups xs

let setify xs = xs |> List.sort compare |> rem_dups

let rec move_fringe n xs xys =
  if n = 0 then  xs <> [] else
    let xs' = List.map (fun x -> get_next x xys) xs |> List.concat |> setify in
    move_fringe (n-1) xs' xys

let test_loop xys =
  let xs = List.map fst xys |> List.sort_uniq compare in
  move_fringe (1 + List.length xs) xs xys
  
  
  
