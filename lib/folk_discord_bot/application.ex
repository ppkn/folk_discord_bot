defmodule FolkDiscordBot.Application do
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    warn_if_wiki_unconfigured()

    children = [
      FolkDiscordBot.Consumer
    ]

    opts = [strategy: :one_for_one, name: FolkDiscordBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp warn_if_wiki_unconfigured do
    case FolkDiscordBot.wiki_client() do
      {:ok, _wiki} ->
        :ok

      {:error, error} ->
        Logger.warning("DokuWiki is not configured, reactions will not be saved",
          error: inspect(error)
        )
    end
  end
end
