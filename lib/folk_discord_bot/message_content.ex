defmodule FolkDiscordBot.MessageContent do
  require Logger
  alias FolkDiscordBot.MessageContent.Media

  defstruct author_name: nil,
            media: [],
            text: "",
            timestamp: nil

  @type t() :: %__MODULE__{
          author_name: String.t() | nil,
          media: [Media.result()],
          text: String.t(),
          timestamp: DateTime.t() | nil
        }

  @spec fetch_and_process(%{channel_id: integer(), message_id: integer()}) ::
          {:ok, t()} | {:error, any()}
  def fetch_and_process(msg) do
    with {:ok, message} <- fetch(msg), do: {:ok, process(message)}
  end

  defp fetch(%{channel_id: channel_id, message_id: message_id}) do
    Logger.info("Fetching message", message_id: message_id)
    Nostrum.Api.Message.get(channel_id, message_id)
  end

  @spec process(Nostrum.Struct.Message.t()) :: t()
  defp process(message) do
    media = Enum.map(message.attachments, &Media.fetch_from_attachment/1)

    %__MODULE__{
      author_name: message.author.username,
      media: media,
      text: message.content,
      timestamp: message.timestamp
    }
  end
end
