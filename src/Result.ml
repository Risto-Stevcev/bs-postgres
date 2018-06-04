type 'a t =
  < rows:     'a array
  ; fields:   <name: string; dataTypeID: int> Js.t array
  ; rowCount: int
  ; command:  string
  > Js.t

let map f x =
  [%bs.obj { rows     = Js.Array.map f x##rows
           ; fields   = x##fields
           ; rowCount = x##rowCount
           ; command  = x##command
           }]
