defmodule RestApi.Model.User do
  defstruct [:id, :name, :email, :password, :stooge]
end

defmodule RestApi.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)
  plug(Plug.Logger, log: :debug)
  plug(Plug.Parsers, parsers: [:json], pass: ["text/*"], json_decoder: Poison)

  get("/",
    do:
      send_resp(
        conn,
        200,
        Poison.encode!(%RestApi.Model.User{
          id: 1,
          name: "Joe",
          email: "joe@example.com",
          password: "topsecret",
          stooge: "moe"
        })
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
