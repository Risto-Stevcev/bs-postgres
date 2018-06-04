type t
type config =
  < user: string Js.undefined
  ; password: string Js.undefined
  ; host: string Js.undefined
  ; database: string Js.undefined
  ; port: int Js.undefined
  ; ssl: <rejectUnauthorized: bool; ca: string; key: string; cert: string> Js.t Js.undefined
  ; statement_timeout: int Js.undefined
  ; connectionTimeoutMillis: int Js.undefined
  ; idleTimeoutMillis: int Js.undefined
  ; max: int Js.undefined
  > Js.t

module Internal = struct
  external make: config -> t = "Pool" [@@bs.module "pg"] [@@bs.new]

  external makeConfig:
    ?user:string ->
    ?password:string ->
    ?host:string ->
    ?database:string ->
    ?port:int ->
    ?ssl: <rejectUnauthorized: bool; ca: string; key: string; cert: string> Js.t ->
    ?statement_timeout:int ->
    ?connectionTimeoutMillis:int ->
    ?idleTimeoutMillis:int ->
    ?max:int ->
    unit ->
    config = "" [@@bs.obj]
end

module Pool_Client = struct
  include Client

  external _release : t -> unit = "release"[@@bs.send ]

  let release client = (client |> _release) |> Js.Promise.resolve
end

module Callback = struct
  external connect:
  t -> (err:Js.Exn.t Js.nullable -> client:Pool_Client.t -> release:(unit -> unit) -> unit) -> unit = "" [@@bs.send]

  external query:
  t -> text:string -> ?values:'a -> (err:Js.Exn.t Js.nullable -> result:'b Result.t -> unit) -> unit = "" [@@bs.send]

  external end_: t -> (unit -> unit) -> unit = "end" [@@bs.send]

  external on:
    t ->
    ([ `connect of Client.t -> unit
     | `acquire of Client.t -> unit 
     | `error   of Js.Exn.t -> Client.t -> unit 
     | `remove  of Client.t -> unit
     ] [@bs.string]) ->
    unit = "" [@@bs.send]
end

module Promise = struct
  external connect: t -> Pool_Client.t Js.Promise.t = "" [@@bs.send]

  external query: string -> ?values:'a -> 'b Result.t Js.Promise.t = "" [@@bs.send.pipe: t]

  external end_: t -> unit Js.Promise.t = "end" [@@bs.send]
end

external totalCount:   t -> int = "" [@@bs.get]
external idleCount:    t -> int = "" [@@bs.get]
external waitingCount: t -> int = "" [@@bs.get]

let make ?user ?password ?host ?database ?port ?ssl ?statement_timeout
         ?connectionTimeoutMillis ?idleTimeoutMillis ?max () =
  Internal.make @@ Internal.makeConfig ?user ?password ?host ?database ?port ?ssl ?statement_timeout
                                       ?connectionTimeoutMillis ?idleTimeoutMillis ?max ()
