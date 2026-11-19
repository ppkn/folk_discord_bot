defmodule FolkDiscordBot.MessageContent do
  @moduledoc """
  The parts of a Discord message needed for the wiki: author, text, timestamp
  and attachments, plus whether the bot has already saved it.

  A saved message carries the bot's own ✅ reaction. Keeping that marker on
  the message itself means it survives restarts and deploys without any other
  storage.

  Attachments are kept as metadata only. Their bytes are downloaded later, one
  at a time, so a message with many large files doesn't hold them all in memory.
  """

  alias Nostrum.Struct.Message.Attachment
  require Logger

  @enforce_keys [:author_name, :attachments, :saved, :text, :timestamp]
  defstruct @enforce_keys

  @type t() :: %__MODULE__{
          author_name: String.t(),
          attachments: [Attachment.t()],
          saved: boolean(),
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

  @doc "The reaction the bot adds to a message once it is saved to the wiki."
  @spec saved_emoji() :: String.t()
  def saved_emoji, do: "✅"

  @doc "The time zone message timestamps are converted to, and newsletters are bucketed by."
  @spec time_zone() :: String.t()
  def time_zone, do: "America/New_York"

  @doc false
  @spec process(Nostrum.Struct.Message.t()) :: t()
  def process(message) do
    %__MODULE__{
      author_name: message.author.username,
      attachments: message.attachments,
      saved: saved?(message.reactions),
      text: message.content,
      timestamp: DateTime.shift_zone!(message.timestamp, time_zone())
    }
  end

  defp saved?(reactions) do
    Enum.any?(reactions || [], &(&1.me and &1.emoji.name == saved_emoji()))
  end
end
