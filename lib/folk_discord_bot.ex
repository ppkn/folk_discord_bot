defmodule FolkDiscordBot do
  @moduledoc """
  Copies Discord messages to the DokuWiki newsletter.

  When a member with the `folk-system-havers` role reacts to a message with 📰,
  the message and its attachments are appended to that month's newsletter page.
  """

  alias FolkDiscordBot.{Member, MessageContent, WikiPage}
  alias Nostrum.Cache.GuildCache
  require Logger

  @spec handle_message_reaction(Nostrum.Struct.Event.MessageReactionAdd.t()) :: :ok
  def handle_message_reaction(event) do
    with :ok <- check_emoji(event.emoji),
         {:ok, guild} <- fetch_guild(event.guild_id),
         :ok <- check_role(event.member, guild),
         {:ok, wiki} <- wiki_client(),
         {:ok, message_content} <- MessageContent.fetch_and_process(event),
         :ok <- update_page(wiki, message_content) do
      Logger.info("Updated page", page: WikiPage.name(message_content))
    else
      {:skip, reason} -> Logger.info("Skipping reaction processing", reason: reason)
      {:error, error} -> Logger.error("Failed to process reaction", error: inspect(error))
    end
  end

  defp check_emoji(%{name: "📰"}), do: :ok
  defp check_emoji(%{name: emoji}), do: {:skip, "reaction was #{emoji}"}

  defp fetch_guild(guild_id) do
    case GuildCache.get(guild_id) do
      {:ok, guild} -> {:ok, guild}
      {:error, :not_found} -> {:error, {:guild_not_cached, guild_id}}
    end
  end

  defp check_role(member, guild) do
    if Member.has_role?(member, guild, "folk-system-havers") do
      :ok
    else
      {:skip, "Non folk-system-havers reaction"}
    end
  end

  defp wiki_client do
    :folk_discord_bot
    |> Application.get_env(:dokuwiki, [])
    |> DokuWiki.new()
  end

  defp update_page(wiki, message_content) do
    uploads = Enum.map(message_content.media, &upload_media(wiki, &1))
    wiki_content = WikiPage.render(message_content, uploads)

    DokuWiki.append_page(wiki, WikiPage.name(message_content), wiki_content)
  end

  defp upload_media(_wiki, {:error, _reason} = error), do: error

  defp upload_media(wiki, {:ok, media}) do
    filename = WikiPage.media_name(media)

    case DokuWiki.save_media(wiki, filename, Base.encode64(media.bytes)) do
      :ok ->
        {:ok, filename}

      {:error, error} ->
        Logger.error("Failed to upload media to DokuWiki", error: inspect(error))
        {:error, "Unable to upload #{media.name} to DokuWiki"}
    end
  end
end
