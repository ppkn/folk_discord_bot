defmodule FolkDiscordBot.WikiPage do
  @moduledoc """
  Names wiki pages and media, and renders message content as DokuWiki markup.
  """

  alias FolkDiscordBot.MessageContent
  alias FolkDiscordBot.MessageContent.Media

  @namespace "newsletters"

  @type upload() :: {:ok, String.t()} | {:error, String.t()}

  @spec name(MessageContent.t()) :: String.t()
  def name(%{timestamp: timestamp}), do: Calendar.strftime(timestamp, "#{@namespace}:%Y-%m")

  @spec media_name(Media.t()) :: String.t()
  def media_name(%{id: id, name: name}), do: "#{@namespace}:#{short_id(id)}_#{name}"

  @spec render(MessageContent.t(), [upload()]) :: String.t()
  def render(message_content, uploads) do
    """

    === #{message_content.author_name} | #{DateTime.to_string(message_content.timestamp)} ===
    #{message_content.text}

    #{render_uploads(uploads)}
    """
  end

  defp render_uploads(uploads) do
    Enum.map_join(uploads, fn
      {:ok, filename} -> "{{#{filename}}}\n"
      {:error, reason} -> "[[ERROR|#{reason}]]\n"
    end)
  end

  # Discord snowflakes are 17-19 digits. The trailing digits change fastest,
  # so keeping the last 6 is enough to tell attachments apart.
  defp short_id(id), do: id |> Integer.to_string() |> String.slice(-6, 6)
end
