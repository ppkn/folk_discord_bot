defmodule FolkDiscordBot.MessageContent.Media do
  require Logger

  defstruct [:bytes, :name]

  @type t() :: %__MODULE__{
          bytes: binary(),
          name: String.t()
        }

  def fetch_from_attachment(%{filename: filename, url: url}) do
    Logger.info("Fetching media", filename: filename, url: url)

    %__MODULE__{
      bytes: fetch_bytes(url),
      name: filename
    }
  end

  defp fetch_bytes(url) do
    case Req.get(url, decode_body: false) do
      {:ok, %Req.Response{status: 200, body: body}} when is_binary(body) ->
        IO.puts("Successfully fetched #{byte_size(body)} bytes")
        body

      _ ->
        Logger.warning("Unable to fetch image from Discord", url: url)
        nil
    end
  end
end
