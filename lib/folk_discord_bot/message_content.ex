defmodule FolkDiscordBot.MessageContent do
  require Logger
  alias FolkDiscordBot.MessageContent.Media

  defstruct author_name: nil,
            message: nil,
            media: [],
            text: "",
            timestamp: nil

  @type t() :: %__MODULE__{
          author_name: String.t() | nil,
          message: Nostrum.Struct.Message.t() | nil,
          media: [Media.t()],
          text: String.t(),
          timestamp: DateTime.t() | nil
        }

  @spec fetch_and_process(%{channel_id: integer(), message_id: integer()}) ::
          {:ok, t()} | {:error, any()}
  def fetch_and_process(msg) do
    with {:ok, message} <- fetch(msg), do: process(message)
  end

  defp fetch(%{channel_id: channel_id, message_id: message_id}) do
    Logger.info("Fetching message", message_id: message_id)
    Nostrum.Api.Message.get(channel_id, message_id)
  end

  defp fetch(msg), do: {:error, "Need channel_id and message_id, got #{inspect(Map.keys(msg))}"}

  @spec process(Nostrum.Struct.Message.t()) :: {:ok, t()}
  defp process(message) do
    author_name = message.author.username
    text = message.content
    timestamp = message.timestamp

    media =
      Enum.map(message.attachments, fn attachment ->
        Media.fetch_from_attachment(attachment)
      end)

    {:ok,
     %__MODULE__{
       author_name: author_name,
       media: media,
       text: text,
       timestamp: timestamp
     }}
  end
end
