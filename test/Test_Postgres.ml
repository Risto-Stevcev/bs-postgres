open BsMocha.Promise
open Test_Helpers

let (resolve, then_) = Js.Promise.(resolve, then_)
let (describe, describe_skip) = BsMocha.Mocha.(describe, describe_skip);;

describe "Postgres" @@ fun () -> begin
  let client = Client.make ~host:"localhost" ~user:"postgres" ~database:"test_bs_postgres" ~port:5432 () in

  let _ =
    before @@ fun () -> client |> setup

  and _ =
    describe "Client" @@ fun () -> begin
      let _ = 
        it "should perform a query" @@ fun () -> client |> test_query
      in
        it "should perform a query using a query object" @@ fun () -> client |> test_query_object
    end

  and _ =
    describe "Pool" @@ fun () -> begin
      let pool = Pool.make ~host:"localhost" ~user:"postgres" ~database:"test_bs_postgres" ~port:5432 () in

      let _ =
        it "should return a releasable client object that can successfully perform queries" @@ fun () ->
          pool
          |> Pool.Promise.connect
          |> then_ test_query
          |> then_ test_query_object
          |> then_ Pool.Pool_Client.release

      in
        after @@ fun () -> pool |> Pool.Promise.end_
    end

  in
    after @@ fun () -> client |> teardown
end
