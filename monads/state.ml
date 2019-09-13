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

module IntState : (STATE with type s = int) = struct
  type s = int
  let emp = 0
end

module Stateful = struct
  module SM = StateMonad(IntState)
  open SM

  let seq x y =
    x >>= fun _ ->
    y >>= fun y ->
    unit y
      
  let (+) x y =
    x >>= fun x ->
    y >>= fun y ->
    unit (x + y)
  
  let inc s =
    let n = get in
    (n + unit 1) >>= fun n ->
    seq (set n) get
    
  let u = unit ()

  let _ =
    let foo = inc() + inc () + inc () in 
    run foo
end
