defmodule FolkDiscordBot.MessageContent do
  @moduledoc """
  The parts of a Discord message needed for the wiki: author, text, timestamp
  and fetched attachments.
  """

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

  @spec fetch_and_process(Nostrum.Struct.Event.MessageReactionAdd.t()) ::
          {:ok, t()} | {:error, term()}
  def fetch_and_process(event) do
    with {:ok, message} <- fetch(event), do: {:ok, process(message)}
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
