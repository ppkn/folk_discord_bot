defmodule FolkDiscordBot do
  alias FolkDiscordBot.{Member, MessageContent}
  require Logger

  @spec handle_message_reaction(Nostrum.Struct.Event.MessageReactionAdd.t()) :: any()
  def handle_message_reaction(msg) do
    with :ok <- check_emoji(msg.emoji),
         :ok <- check_role(msg),
         {:ok, message_content} <- MessageContent.fetch_and_process(msg),
         :ok <- update_page(message_content) do
      Logger.info("Updated page", page: page_name(message_content))
    else
      {:skip, reason} -> Logger.info("Skipping reaction processing", reason: reason)
      {:error, error} -> Logger.error("Failed to process reaction", error: inspect(error))
    end
  end

  defp build_wiki_content(message_content) do
    media = Enum.map(message_content.media, &upload_media/1)

    """

    === #{message_content.author_name} | #{DateTime.to_string(message_content.timestamp)} ===
    #{message_content.text}

    #{render_media(media)}
    """
  end

  defp render_media(media) do
    Enum.map_join(media, fn
      {:ok, filename} -> "{{#{filename}}}\n"
      {:skip, reason} -> "[[ERROR|#{reason}]]\n"
    end)
  end

  defp check_emoji(%{name: "📰"}), do: :ok
  defp check_emoji(%{name: emoji}), do: {:skip, "reaction was #{emoji}"}

  defp check_role(msg) do
    if Member.has_role?(msg.member, msg.guild_id, "folk-system-havers"),
      do: :ok,
      else: {:skip, "Non folk-system-havers reaction"}
  end

  defp page_name(%{timestamp: timestamp}) do
    year = timestamp.year
    month = timestamp.month |> Integer.to_string() |> String.pad_leading(2, "0")
    "newsletters:#{year}-#{month}"
  end

  defp update_page(message_content) do
    page_name = page_name(message_content)
    wiki_content = build_wiki_content(message_content)

    DokuwikiApi.append_page(page_name, wiki_content)
  end

  defp upload_media(%{bytes: nil, name: name}),
    do: {:skip, "Unable to fetch #{name} from Discord"}

  defp upload_media(%{bytes: bytes, name: name}) do
    filename = "newsletters:#{name}"

    case DokuwikiApi.save_media(filename, Base.encode64(bytes)) do
      :ok ->
        {:ok, filename}

      {:error, error} ->
        Logger.error("Failed to upload media to DokuWiki", error: inspect(error))
        {:skip, "Unable to upload #{name} to DokuWiki"}
    end
  end
end
