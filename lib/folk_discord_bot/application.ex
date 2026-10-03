defmodule FolkDiscordBot.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FolkDiscordBot.Consumer
    ]

    opts = [strategy: :one_for_one, name: FolkDiscordBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
