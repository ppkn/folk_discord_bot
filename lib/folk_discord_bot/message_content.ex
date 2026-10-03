defmodule FolkDiscordBot.MessageContent do
  @moduledoc """
  The parts of a Discord message needed for the wiki: author, text, timestamp
  and attachments.

  Attachments are kept as metadata only. Their bytes are downloaded later, one
  at a time, so a message with many large files doesn't hold them all in memory.
  """

  alias Nostrum.Struct.Message.Attachment
  require Logger

  @enforce_keys [:author_name, :attachments, :text, :timestamp]
  defstruct @enforce_keys

  @type t() :: %__MODULE__{
          author_name: String.t(),
          attachments: [Attachment.t()],
          text: String.t(),
          timestamp: DateTime.t()
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
    %__MODULE__{
      author_name: message.author.username,
      attachments: message.attachments,
      text: message.content,
      timestamp: message.timestamp
    }
  end
end
