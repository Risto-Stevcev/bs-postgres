type 'a t

external make: text:string -> ?values:'a -> ?name:string -> ?rowMode:string -> unit -> 'b t = "" [@@bs.obj]
