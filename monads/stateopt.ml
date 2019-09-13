module type STATE =
sig
  type s
  val emp : s
end

module type MONAD =
  sig
    type 'a m
    val map  : ('a -> 'b) -> ('a m -> 'b m)
    val mult : 'a m m -> 'a m
    val unit : 'a -> 'a m
  end
  
module type STATE_MONAD = 
  functor(State : STATE) ->
  sig
    include MONAD
    (* Special operations *)
    val run  : 'a m -> 'a 
    val set  : State.s -> unit m
    val get  : State.s m
    val ( >>= ) : 'a m -> ('a -> 'b m) -> 'b m
  end

module StateMonad : (STATE_MONAD) =
   functor (State : STATE) ->
     struct
       type 'a m = State.s -> ('a * State.s)
                               
       let (map : ('a -> 'b) -> ('a m -> 'b m)) =
         fun f a s -> let (a', s') = a s in (f a', s')
                                                
       let (mult : 'a m m -> 'a m) =
         fun att s0 -> let (at, s1) = att s0 in at s1
           
       let (unit : 'a -> 'a m) =
         fun a s -> (a, s)
                        
       let (run : 'a m -> 'a ) =
         fun m -> m State.emp |> fst

       let (set : State.s -> unit m) =
         fun s _ -> ((), s)

       let (get : State.s m) =
         fun s -> (s, s)

       (* Bind *)
       let (>>=) at f = at |> (map f) |> mult

     end

module IntState : (STATE with type s = int option) = struct
  type s = int option 
  let emp = None
end

module Stateful = struct
  module SM = StateMonad(IntState)
  open SM

  let (+) m n = match m, n with
    | Some m, Some n -> Some (m + n)
    | _, _ -> None 
  
  let inc s =
    get         >>= fun n  ->
    set (n + (Some 1)) >>= fun () ->
    get

  let (+) x y =
    x >>= fun x ->
    y >>= fun y ->
    unit (x + y)
  
  let x =
    let foo = inc() + inc () + inc () in 
    run
      (set (Some 0) >>= fun () ->
      foo)
end

open Stateful
let int_of_intoption = function None -> 0 | Some n -> n
let _ =
  if (int_of_intoption x) = 6 then print_endline("1") else print_endline("0")