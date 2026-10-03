defmodule FolkDiscordBot.MediaTest do
  use ExUnit.Case, async: true

  alias FolkDiscordBot.Media

  @moduletag :capture_log

  test "skips attachments over the size limit without fetching them" do
    attachment = %{id: 1, filename: "big.mov", size: 26 * 1024 * 1024, url: "http://unused.test"}

    assert Media.fetch_from_attachment(attachment) == {:error, "big.mov is larger than 25MB"}
  end
end
