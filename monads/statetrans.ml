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
    val commit : unit -> unit m
    val rollback : unit -> unit m
  end

module TransStateMonad : (STATE_MONAD) =
   functor (State : STATE) ->
     struct
       type 'a m = State.s list -> ('a * (State.s list))
                               
       let (map : ('a -> 'b) -> ('a m -> 'b m)) =
         fun f a s -> let (a', s') = a s in (f a', s')
                                                
       let (mult : 'a m m -> 'a m) =
         fun att s0 -> let (at, s1) = att s0 in at s1
           
       let (unit : 'a -> 'a m) =
         fun a s -> (a, s)
                        
       let (run : 'a m -> 'a ) =
         fun m -> m [State.emp] |> fst

       let (set : State.s -> unit m) =
         fun s s' -> ((), s :: s')

       let (get : State.s m) =
         fun s -> (List.hd s, s)

       (* Bind *)
       let (>>=) at f = at |> (map f) |> mult

       let commit () = fun s -> ((), [List.hd s])        

       let rollback () = fun s -> ((), [List.rev s |> List.hd])
     end

module IntState : (STATE with type s = int) = struct
  type s = int
  let emp = 0
end

module Stateful = struct
  module SM = TransStateMonad(IntState)
  open SM

  let inc s =
    get         >>= fun n  ->
    set (n + 1) >>= fun () ->
    get

  let (+) x y =
    x >>= fun x ->
    y >>= fun y ->
    unit (x + y)
  
  let x =
    let foo = inc() + inc () + inc () in 
    run foo

  let y =
    inc () >>= fun x ->
    inc () >>= fun y ->
    unit (print_int x; print_int y; print_newline ()) >>= fun () ->
    rollback () >>= fun () ->
    inc () >>= fun x ->
    inc () >>= fun y ->
    unit (print_int x; print_int y; print_newline ()) >>= fun () ->
    commit () >>= fun () ->
    inc () >>= fun x ->
    inc () >>= fun y ->
    unit (print_int x; print_int y; print_newline ()) >>= fun () ->
    rollback () >>= fun () ->
    inc () >>= fun x ->
    inc () >>= fun y ->
    unit (print_int x; print_int y; print_newline ())

  let f () = run y
    
end

module Test = struct
  open Stateful

  let _ = f ()
  
end