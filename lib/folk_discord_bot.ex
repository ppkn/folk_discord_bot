defmodule FolkDiscordBot do
  alias FolkDiscordBot.{Member, MessageContent, WikiPage}
  require Logger

  @spec handle_message_reaction(Nostrum.Struct.Event.MessageReactionAdd.t()) :: any()
  def handle_message_reaction(msg) do
    with :ok <- check_emoji(msg.emoji),
         :ok <- check_role(msg),
         {:ok, wiki} <- wiki_client(),
         {:ok, message_content} <- MessageContent.fetch_and_process(msg),
         :ok <- update_page(wiki, message_content) do
      Logger.info("Updated page", page: WikiPage.name(message_content))
    else
      {:skip, reason} -> Logger.info("Skipping reaction processing", reason: reason)
      {:error, error} -> Logger.error("Failed to process reaction", error: inspect(error))
    end
  end

  defp check_emoji(%{name: "📰"}), do: :ok
  defp check_emoji(%{name: emoji}), do: {:skip, "reaction was #{emoji}"}

  defp check_role(msg) do
    if Member.has_role?(msg.member, msg.guild_id, "folk-system-havers"),
      do: :ok,
      else: {:skip, "Non folk-system-havers reaction"}
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
