defmodule FolkDiscordBot.WikiPage do
  @moduledoc """
  Names wiki pages and media, and renders message content as DokuWiki markup.
  """

  alias FolkDiscordBot.{Media, MessageContent}

  @namespace "newsletters"

  @type upload() :: {:ok, String.t()} | {:error, String.t()}

  @spec name(MessageContent.t()) :: String.t()
  def name(%{timestamp: timestamp}), do: Calendar.strftime(timestamp, "#{@namespace}:%Y-%m")

  @doc """
  Whether the message is too old to add to the wiki.

  Only the current and previous month's newsletters may be updated. Months
  are those of the message's own time zone (see `MessageContent.time_zone/0`).
  """
  @spec too_old?(MessageContent.t(), DateTime.t()) :: boolean()
  def too_old?(%{timestamp: timestamp}, now \\ DateTime.utc_now()) do
    cutoff =
      now
      |> DateTime.shift_zone!(timestamp.time_zone)
      |> DateTime.to_date()
      |> Date.beginning_of_month()
      |> Date.shift(month: -1)

    Date.compare(DateTime.to_date(timestamp), cutoff) == :lt
  end

  @spec media_name(Media.t()) :: String.t()
  def media_name(%{id: id, name: name}), do: "#{@namespace}:#{short_id(id)}_#{name}"

  @spec render(MessageContent.t(), [upload()]) :: String.t()
  def render(message_content, uploads) do
    """

    === #{message_content.author_name} | #{format_timestamp(message_content.timestamp)} ===
    #{format_text(message_content.text)}

    #{render_uploads(uploads)}
    """
  end

  # DokuWiki joins single newlines into one paragraph, so mark line breaks with
  # `\\`. Blank lines already start a new paragraph and are left alone.
  defp format_text(text) do
    text
    |> String.split(~r/\n{2,}/)
    |> Enum.map_join("\n\n", &String.replace(&1, "\n", "\\\\\n"))
  end

  defp format_timestamp(timestamp), do: Calendar.strftime(timestamp, "%Y-%m-%d %H:%M %Z")

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
