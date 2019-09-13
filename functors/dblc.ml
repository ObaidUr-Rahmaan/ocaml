module CircleSpec : DBLCIRCULAR = struct
  exception Empty;;

  type 'a circular_cell = { mutable rev_cell : 'a circular_cell option; mutable value : 'a; mutable fwd_cell : 'a circular_cell option; };;
  type 'a circular = { mutable current_cell :'a circular_cell option };;

  let create value = let current_cell = { rev_cell = None; value; fwd_cell = None } in
      current_cell.rev_cell <- Some current_cell;
      current_cell.fwd_cell <- Some current_cell;
      { current_cell = Some current_cell };;

  let empty c = c.current_cell == None;;

  let peek c = match c.current_cell with
  | None -> raise Empty
  | Some current_cell -> current_cell.value;;

  let val_of_option = function Some x -> x | None -> failwith "val_of_option";;

  let ins value c = match c.current_cell with
  | None -> 
      let new_c = create value in 
      c.current_cell <- new_c.current_cell; 
      ()
  | Some current_cell -> 
      let rev_cell = current_cell.rev_cell in
      let new_cell = { rev_cell; value; fwd_cell = Some current_cell; } in
      (val_of_option rev_cell).fwd_cell <- Some new_cell;
      current_cell.rev_cell <- Some new_cell;
      c.current_cell <- Some new_cell;
      ();;

  let del c = match c.current_cell with
  | None -> raise Empty
  | Some current_cell -> 
      let rev_cell = val_of_option current_cell.rev_cell in
      if rev_cell == current_cell 
      then 
          begin
              c.current_cell <- None;
              ()
          end
      else 
          begin
              let fwd_cell = val_of_option current_cell.fwd_cell in 
              rev_cell.fwd_cell <- current_cell.fwd_cell; 
              fwd_cell.rev_cell <- Some rev_cell;
              c.current_cell <- Some fwd_cell;
              ()
          end;;

  let fwd c = match c.current_cell with
  | None -> raise Empty
  | Some cell -> c.current_cell <- cell.fwd_cell;
  ();;

  let rev c = match c.current_cell with
  | None -> raise Empty
  | Some cell -> c.current_cell <- cell.rev_cell;
  ();;

  let fold c a f = match c.current_cell with
  | None -> a
  | Some cell -> 
      let move_forward c = val_of_option c.fwd_cell in
      let rec aux s c a f = 
          if s == c 
          then a
          else aux s (move_forward c) (f a c.value) f
      in aux cell (move_forward cell) (f a cell.value) f;;
end;;
