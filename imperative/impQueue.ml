exception Emptyq

type 'a element =
  {          
    value : 'a;
    mutable next  : 'a element option;
  }

type 'a queue =
  { 
    mutable head : 'a element option;
    mutable tail : 'a element option
  }

let val_of_option = function Some x -> x | None -> failwith "val_of_option"

let newq () = {head = None; tail = None;}

let enq q a =
  let newe = {value = a; next = None} in
  if q.head = None && q.tail = None
  then
    begin
      q.head <- Some newe;
      q.tail <- Some newe
    end
  else
    begin
      (val_of_option q.tail).next <- Some newe;
      q.tail <- Some newe
    end

let deq q =
  if q.head = None || q.tail = None then raise Emptyq
  else if q.head = q.tail
  then
    begin
      let x = (val_of_option q.head).value in 
      q.head <- None;
      q.tail <- None;
      x
    end
  else
    let x = (val_of_option q.head).value in 
    q.head <- (val_of_option q.head).next;
    x