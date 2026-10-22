import Config

http_port =
  if config_env() != :test,
    do: System.get_env("TODO_HTTP_PORT", "4100"),
    else: System.get_env("TODO_HTTP_PORT", "4110")

db_folder =
  if config_env() != :test,
    do: System.get_env("TODO_DB_FOLDER", "./persist"),
    else: System.get_env("TODO_DB_FOLDER", "./persist_test")

config :elixir_demo, http_port: String.to_integer(http_port)

config :elixir_demo,
  db_folder: db_folder,
  pool_size: 3
