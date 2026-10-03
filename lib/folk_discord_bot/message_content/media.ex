defmodule FolkDiscordBot.MessageContent.Media do
  require Logger

  @max_mb 25
  @max_bytes @max_mb * 1024 * 1024

  defstruct [:id, :bytes, :name]

  @type t() :: %__MODULE__{
          id: Nostrum.Snowflake.t(),
          bytes: binary(),
          name: String.t()
        }

  @type result() :: {:ok, t()} | {:error, String.t()}

  @spec fetch_from_attachment(Nostrum.Struct.Message.Attachment.t()) :: result()
  def fetch_from_attachment(%{filename: filename, size: size}) when size > @max_bytes do
    Logger.warning("Skipping oversized media", filename: filename)
    {:error, "#{filename} is larger than #{@max_mb}MB"}
  end

  def fetch_from_attachment(%{id: id, filename: filename, url: url}) do
    Logger.info("Fetching media", filename: filename, url: url)

    case fetch_bytes(url) do
      {:ok, bytes} ->
        {:ok, %__MODULE__{id: id, bytes: bytes, name: filename}}

      {:error, reason} ->
        Logger.warning("Unable to fetch media from Discord", url: url, reason: inspect(reason))
        {:error, "Unable to fetch #{filename} from Discord"}
    end
  end

  defp fetch_bytes(url) do
    case Req.get(url, decode_body: false) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        Logger.info("Fetched media", url: url, byte_count: byte_size(body))
        {:ok, body}

      {:ok, %Req.Response{status: status}} ->
        {:error, {:http_status, status}}

      {:error, exception} ->
        {:error, exception}
    end
  end
end
