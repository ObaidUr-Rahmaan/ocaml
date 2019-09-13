
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