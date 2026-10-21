import Config

http_port = System.get_env("TODO_HTTP_PORT", "4100")

config :elixir_demo, http_port: String.to_integer(http_port)
