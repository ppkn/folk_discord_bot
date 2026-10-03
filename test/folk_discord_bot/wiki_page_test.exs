defmodule FolkDiscordBot.WikiPageTest do
  use ExUnit.Case, async: true

  alias FolkDiscordBot.WikiPage

  @message_content %{
    author_name: "dpip",
    timestamp: ~U[2026-10-02 01:56:40.273000Z],
    text: "hello",
    media: []
  }

  describe "name/1" do
    test "zero-pads the month" do
      assert WikiPage.name(%{timestamp: ~U[2026-01-05 00:00:00Z]}) == "newsletters:2026-01"
    end

    test "handles two-digit months" do
      assert WikiPage.name(%{timestamp: ~U[2026-12-31 23:59:59Z]}) == "newsletters:2026-12"
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

      assert content =~ "=== dpip | 2026-10-02 01:56 UTC ==="
      assert content =~ "hello"
    end

    test "renders uploaded files and errors in order" do
      content = WikiPage.render(@message_content, [{:ok, "newsletters:a.png"}, {:error, "boom"}])

      assert content =~ "{{newsletters:a.png}}\n[[ERROR|boom]]\n"
    end
  end
end
