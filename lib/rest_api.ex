defmodule RestApi.Model.User do
  defstruct [:id, :name, :email, :password, :stooge]
end

defmodule RestApi.Repository do
  def users do
    [
      %RestApi.Model.User{
        id: 1,
        name: "Joe",
        email: "joe@example.com",
        password: "topsecret",
        stooge: "moe"
      },
      %RestApi.Model.User{
        id: 2,
        name: "Bob",
        email: "bob2@example.com",
        password: "topsecret",
        stooge: "moe"
      }
    ]
  end

  def get_all() do
    users()
  end

  def get_by_id(id) do
    Enum.at(users(), id)
  end
end

defmodule RestApi.Router do
  use Plug.Router
  require RestApi.Repository

  plug(:match)
  plug(:dispatch)
  plug(Plug.Logger, log: :debug)
  plug(Plug.Parsers, parsers: [:json], pass: ["text/*"], json_decoder: Poison)

  get("/",
    do:
      send_resp(
        conn,
        200,
        RestApi.Repository.get_all()
        |> Poison.encode!()
      )
  )

  get("/:id",
    do:
      send_resp(
        conn,
        200,
        elem(Integer.parse(id), 0)
        |> RestApi.Repository.get_by_id()
        |> Poison.encode!()
      )
  )

  match(_, do: send_resp(conn, 404, "Not found"))
end

defmodule RestApi.Application do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, RestApi.Router, [], port: 8000)
    ]

    Logger.info("Started application")

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
