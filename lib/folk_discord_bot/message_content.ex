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
    case fetch(msg) do
      {:ok, message} -> process(message)
      {:error, error} -> {:error, error}
    end
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

  # {:ok, message} = Nostrum.Api.Message.get(channel_id, message_id)
  # IO.inspect(message)
  # %Nostrum.Struct.Message{
  #   activity: nil,
  #   application: nil,
  #   application_id: nil,
  #   attachments: [
  #     %Nostrum.Struct.Message.Attachment{
  #       id: 1555398079622942791,
  #       filename: "shocked_pikachu.png",
  #       size: 81136,
  #       url: "https://cdn.discordapp.com/attachments/1553815292587679834/1555398079622942791/shocked_pikachu.png?backend=b2&ex=6ac060d8&is=6abf0f58&hm=061edb0ca9c76b11c963208c6c72a3551e7bc10420fe068c5f87007c0696c965&",
  #       proxy_url: "https://media.discordapp.net/attachments/1553815292587679834/1555398079622942791/shocked_pikachu.png?backend=b2&ex=6ac060d8&is=6abf0f58&hm=061edb0ca9c76b11c963208c6c72a3551e7bc10420fe068c5f87007c0696c965&",
  #       height: 232,
  #       width: 400
  #     }
  #   ],
  #   author: %Nostrum.Struct.User{
  #     id: 248126340107075585,
  #     username: "dpip",
  #     discriminator: "0",
  #     global_name: "dpip",
  #     avatar: "322afe44047724dd6b73d5d8b18a52d1",
  #     bot: nil,
  #     public_flags: 0
  #   },
  #   channel_id: 1553815292587679834,
  #   content: "I like this surprised Pikachu.",
  #   components: [],
  #   edited_timestamp: nil,
  #   embeds: [],
  #   id: 1555398080428245003,
  #   interaction: nil,
  #   guild_id: nil,
  #   member: nil,
  #   mention_everyone: false,
  #   mention_roles: [],
  #   mention_channels: nil,
  #   mentions: [],
  #   message_reference: nil,
  #   nonce: nil,
  #   pinned: false,
  #   poll: nil,
  #   reactions: [
  #     %Nostrum.Struct.Message.Reaction{
  #       count: 1,
  #       me: false,
  #       emoji: %Nostrum.Struct.Emoji{
  #         id: nil,
  #         name: "📰",
  #         user: nil,
  #         require_colons: nil,
  #         managed: nil,
  #         animated: nil,
  #         roles: nil
  #       }
  #     },
  #     %Nostrum.Struct.Message.Reaction{
  #       count: 1,
  #       me: false,
  #       emoji: %Nostrum.Struct.Emoji{
  #         id: nil,
  #         name: "🪩",
  #         user: nil,
  #         require_colons: nil,
  #         managed: nil,
  #         animated: nil,
  #         roles: nil
  #       }
  #     }
  #   ],
  #   referenced_message: nil,
  #   sticker_items: nil,
  #   timestamp: ~U[2026-10-02 01:56:40.273000Z],
  #   thread: nil,
  #   tts: false,
  #   type: 0,
  #   webhook_id: nil
  # }
end
