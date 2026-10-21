defmodule TodoWeb do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    title = Map.fetch!(conn.params, "title")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    list_name
    |> TodoCache.server_process()
    |> TodoGenServer.add_entry(%{date: date, title: title})

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  get "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    entries =
      list_name
      |> TodoCache.server_process()
      |> TodoGenServer.entries(date)

    formatted_entries =
      entries
      |> Enum.map(fn entry -> "#{entry.date} - #{entry.title}" end)
      |> Enum.join("\n")

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, formatted_entries)
  end

  def child_spec(_) do
    Plug.Cowboy.child_spec(
      scheme: :http,
      options: [port: 4100],
      plug: __MODULE__
    )
  end
end
