defmodule Couch.Test do
  use ExUnit.Case
  doctest Couch

  setup do
    url = Application.get_env(:couch, :url)
    dbname = "test_database"
    repl_dbname = "test_replication"
    create_dbname = "test_create"
    {:ok, [url: url, dbname: dbname, repl_dbname: repl_dbname, create_dbname: create_dbname]}
  end

  test "server_connection via url", %{url: url} do
    assert Couch.server_connection == %Couch.Server{url: "http://127.0.0.1:5984/"}
    assert Couch.server_connection("http://127.0.0.1:5984") == %Couch.Server{url: "http://127.0.0.1:5984/"}
    assert Couch.server_connection("http://127.0.0.1:5984", [bla: 123]) == %Couch.Server{url: "http://127.0.0.1:5984/", options: [bla: 123]}
    assert Couch.server_connection url
  end

  test "server_connection via host, port etc" do
    assert Couch.server_connection("localhost", 5984) == %Couch.Server{url: "http://localhost:5984/"}
    assert Couch.server_connection("localhost", 443) == %Couch.Server{url: "https://localhost:443/"}
    assert Couch.server_connection("localhost", 4430, "", [is_ssl: true]) == %Couch.Server{url: "https://localhost:4430/", options: [is_ssl: true]}
    assert Couch.server_connection("localhost", 4430, "prefix", [is_ssl: true]) == %Couch.Server{url: "https://localhost:4430/prefix/", options: [is_ssl: true]}
  end

  test "server_info", %{url: url} do
    connection = Couch.server_connection url
    {:ok, resp} = Couch.server_info(connection)
    assert Map.get(resp, "couchdb") == "Welcome"
    assert Map.get(resp, "version") 
  end

  test "get_uuid", %{url: url} do
    connection = Couch.server_connection url
    uuids = Couch.get_uuid(connection, 10)
    assert length(uuids) == 10
    assert String.length(hd(uuids)) == 32
  end

  test "replicate", %{url: url, dbname: dbname, repl_dbname: repl_dbname} do
    connection = Couch.server_connection url
    repl_obj = %{source: dbname, target: repl_dbname, create_target: true}
    {:ok, resp} = Couch.replicate(connection, repl_obj)
    assert Map.get(resp, "ok") == true

    repl_obj = %{source: "non existing db", target: repl_dbname, create_target: true}
    assert {:error, _} = Couch.replicate(connection, repl_obj)
  end

  test "replicate shortcuts", %{url: url, dbname: dbname, repl_dbname: repl_dbname} do
    connection = Couch.server_connection url
    db1 = %Couch.DB{server: connection, name: dbname}
    db2 = %Couch.DB{server: connection, name: repl_dbname}
    {:ok, resp} = Couch.replicate(connection, dbname, repl_dbname, %{create_target: true})
    assert Map.get(resp, "ok") == true
    {:ok, resp} = Couch.replicate(connection, db1, repl_dbname, %{create_target: true})
    assert Map.get(resp, "ok") == true
    {:ok, resp} = Couch.replicate(connection, dbname, db2, %{create_target: true})
    assert Map.get(resp, "ok") == true
    {:ok, resp} = Couch.replicate(connection, db1, db2, %{create_target: true})
    assert Map.get(resp, "ok") == true
  end

  test "all_dbs", %{url: url} do
    connection = Couch.server_connection url
    result = Couch.all_dbs(connection)
    assert {:ok, resp} = result
    assert is_list(resp) == true
    assert length(resp) > 1
    assert Enum.member?(resp, "_users")
  end

  test "db_exists", %{url: url, dbname: dbname} do
    connection = Couch.server_connection url
    result = Couch.db_exists(connection, dbname)
    assert result
    result = Couch.db_exists(connection, "non existing db")
    assert !result
  end

  test "create_db, delete_db", %{url: url, create_dbname: create_dbname} do
    connection = Couch.server_connection url

    if Couch.db_exists(connection, create_dbname) do
      Couch.delete_db(connection, create_dbname)
    end

    {:ok, db} = Couch.create_db(connection, create_dbname)
    assert db.server == connection
    assert db.name == create_dbname

    {:ok, response} = Couch.delete_db(connection, create_dbname)
    assert response["ok"]
    assert !Couch.db_exists(connection, create_dbname)
  end





end
