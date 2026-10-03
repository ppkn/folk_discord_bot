defmodule FolkDiscordBot.MessageContent.Media do
  require Logger

  @max_bytes 25 * 1024 * 1024

  defstruct [:bytes, :name, :error]

  @type t() :: %__MODULE__{
          bytes: binary() | nil,
          name: String.t(),
          error: String.t() | nil
        }

  def fetch_from_attachment(%{filename: filename, size: size}) when size > @max_bytes do
    Logger.warning("Skipping oversized media", filename: filename)

    %__MODULE__{
      bytes: nil,
      name: filename,
      error: "#{filename} is larger than #{div(@max_bytes, 1024 * 1024)}MB"
    }
  end

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
        Logger.info("Fetched media", url: url, byte_count: byte_size(body))
        body

      _ ->
        Logger.warning("Unable to fetch image from Discord", url: url)
        nil
    end
  end
end
