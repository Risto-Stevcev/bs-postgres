module Result = BsPostgres_Result
module Query = BsPostgres_Query

type t
type config =
  < user: string Js.undefined
  ; password: string Js.undefined
  ; host: string Js.undefined
  ; database: string Js.undefined
  ; port: int Js.undefined
  ; ssl: <rejectUnauthorized: bool; ca: string; key: string; cert: string> Js.t Js.undefined
  ; statement_timeout: int Js.undefined
  >  Js.t

module Internal = struct
  external make: config -> t = "Client" [@@bs.module "pg"] [@@bs.new]

  external makeConfig:
    ?user:string ->
    ?password:string ->
    ?host:string ->
    ?database:string ->
    ?port:int ->
    ?ssl: <rejectUnauthorized: bool; ca: string; key: string; cert: string> Js.t ->
    ?statement_timeout:int ->
    unit ->
    config = "" [@@bs.obj]
end

module Callback = struct
  external connect: t -> (Js.Exn.t Js.nullable -> unit) -> unit = "" [@@bs.send]

  external query:
  t -> text:string -> ?values:'a -> (err:Js.Exn.t Js.nullable -> result:'b Result.t -> unit) -> unit = "" [@@bs.send]

  external query':
  t -> 'a Query.t -> (Js.Exn.t Js.nullable -> 'a Result.t Js.nullable -> unit) -> unit = "query" [@@bs.send]

  external end_: t -> (Js.Exn.t Js.nullable -> unit) -> unit = "end" [@@bs.send]

  external on:
    t ->
    ([ `error        of Js.Exn.t -> unit
     | `end_         of unit -> unit
     | `notification of <processId: int; channel: string; payload: string Js.nullable> Js.t -> unit
     | `notice       of string -> unit
     ] [@bs.string]) ->
    unit = "" [@@bs.send]
end

module Promise = struct
  external connect: t -> unit Js.Promise.t = "" [@@bs.send]

  external query: string -> ?values:'a -> 'b Result.t Js.Promise.t = "" [@@bs.send.pipe: t]

  external query': 'a Query.t -> 'a Result.t Js.Promise.t = "query" [@@bs.send.pipe: t]

  external end_: t -> unit Js.Promise.t = "end" [@@bs.send]
end

let make ?user ?password ?host ?database ?port ?ssl ?statement_timeout () =
  Internal.make @@ Internal.makeConfig ?user ?password ?host ?database ?port ?ssl ?statement_timeout ()
