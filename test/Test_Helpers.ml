open BsPostgres
open BsChai.Expect.Expect
open BsChai.Expect.Combos.End
open Client.Promise
open Js.Promise

type fruit = <id: int [@bs.get]; name: string [@bs.get]> Js.t
type vendor = <vendor_name: string [@bs.get]; fruits_id: int [@bs.get]> Js.t

let setup client =
  client
  |> connect
  |> then_ @@ fun _ ->
       query "CREATE TABLE IF NOT EXISTS fruits (id serial PRIMARY KEY NOT NULL, name varchar(20) UNIQUE NOT NULL)" client
  |> then_ @@ fun _ ->
       query ("CREATE TABLE IF NOT EXISTS vendors (vendor_name varchar(20) NOT NULL, fruits_id integer NOT NULL, " ^
              "PRIMARY KEY (vendor_name, fruits_id), FOREIGN KEY (fruits_id) REFERENCES fruits (id))") client
  |> then_ @@ fun _  ->
       query "INSERT INTO fruits VALUES (default, 'avocado')" client
  |> then_ @@ fun _  ->
       query "INSERT INTO fruits VALUES (default, 'banana')" client
  |> then_ @@ fun _  ->
       query "INSERT INTO fruits VALUES (default, 'blueberry')" client
  |> then_ @@ fun _  ->
       query "INSERT INTO fruits VALUES (default, 'raspberry')" client
  |> then_ @@ fun _  ->
       query "INSERT INTO vendors VALUES ('bill',  1)" client
  |> then_ @@ fun _  ->
       query "INSERT INTO vendors VALUES ('frank', 2)" client
  |> then_ @@ fun _  ->
       query "INSERT INTO vendors VALUES ('frank', 3)" client
  |> then_ @@ fun _  ->
       query "INSERT INTO vendors VALUES ('jane',  4)" client

let teardown client =
  client
  |> query "DROP TABLE IF EXISTS vendors"
  |> then_ @@ fun _  -> query "DROP TABLE IF EXISTS fruits" client
  |> then_ @@ fun _  -> end_ client

let test_query client =
  client
  |> query "SELECT * FROM fruits WHERE id > $1" ~values:[|1|]
  |> then_ @@ fun (result : fruit Result.t)  ->
     expect result##rows |> to_deep_equal [|
       [%bs.obj { id = 2; name = "banana"    }];
       [%bs.obj { id = 3; name = "blueberry" }];
       [%bs.obj { id = 4; name = "raspberry" }]
     |];
     resolve client

let test_query_object client =
  client
  |> query' @@ Query.make
     ~text:"SELECT vendor_name AS vendor, name AS fruit FROM vendors JOIN fruits ON id = fruits_id WHERE vendor_name = $1"
     ~values:[|"frank"|] ()
  |> then_ @@ fun (result : vendor Result.t) ->
     expect result##rows |> to_deep_equal [|
       [%bs.obj { fruit = "banana"; vendor = "frank" }];
       [%bs.obj { fruit = "blueberry"; vendor = "frank" }]
     |];
     resolve client
