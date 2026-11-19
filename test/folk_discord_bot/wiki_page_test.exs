defmodule FolkDiscordBot.WikiPageTest do
  use ExUnit.Case, async: true

  alias FolkDiscordBot.WikiPage

  @message_content %{
    author_name: "dpip",
    timestamp: DateTime.shift_zone!(~U[2026-10-02 01:56:40.273000Z], "America/New_York"),
    text: "hello",
    attachments: []
  }

  describe "name/1" do
    test "zero-pads the month" do
      assert WikiPage.name(%{timestamp: ~U[2026-01-05 00:00:00Z]}) == "newsletters:2026-01"
    end

    test "handles two-digit months" do
      assert WikiPage.name(%{timestamp: ~U[2026-12-31 23:59:59Z]}) == "newsletters:2026-12"
    end
  end

  describe "too_old?/2" do
    @now ~U[2026-11-18 12:00:00Z]

    defp ny(utc), do: %{timestamp: DateTime.shift_zone!(utc, "America/New_York")}

    test "allows messages from the current month" do
      refute WikiPage.too_old?(ny(~U[2026-11-05 00:00:00Z]), @now)
    end

    test "allows messages from the start of last month in New York" do
      # 2026-10-01 00:00 EDT
      refute WikiPage.too_old?(ny(~U[2026-10-01 04:00:00Z]), @now)
    end

    test "rejects messages from the end of two months ago in New York" do
      # 2026-09-30 23:59:59 EDT
      assert WikiPage.too_old?(ny(~U[2026-10-01 03:59:59Z]), @now)
    end

    test "uses New York's month for now too" do
      # 2026-12-01 02:00 UTC is still 2026-11-30 in New York, so October is allowed
      refute WikiPage.too_old?(ny(~U[2026-10-01 04:00:00Z]), ~U[2026-12-01 02:00:00Z])
    end

    test "handles year boundaries" do
      now = ~U[2026-01-15 00:00:00Z]
      refute WikiPage.too_old?(ny(~U[2025-12-01 05:00:00Z]), now)
      assert WikiPage.too_old?(ny(~U[2025-12-01 04:59:59Z]), now)
    end
  end

  describe "media_name/1" do
    test "prefixes the filename with the last 6 digits of the attachment id" do
      assert WikiPage.media_name(%{id: 1_555_398_079_622_942_791, name: "image.png"}) ==
               "newsletters:942791_image.png"
    end
  end

  describe "render/2" do
    test "includes the header and text" do
      content = WikiPage.render(@message_content, [])

      assert content =~ "=== dpip | 2026-10-01 21:56 EDT ==="
      assert content =~ "hello"
    end

    test "keeps single line breaks and paragraph breaks" do
      message_content = %{@message_content | text: "one\ntwo\n\n\nthree"}

      assert WikiPage.render(message_content, []) =~ "one\\\\\ntwo\n\nthree\n"
    end

    test "renders uploaded files and errors in order" do
      content = WikiPage.render(@message_content, [{:ok, "newsletters:a.png"}, {:error, "boom"}])

      assert content =~ "{{newsletters:a.png}}\n[[ERROR|boom]]\n"
    end
  end
end
