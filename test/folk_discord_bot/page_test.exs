defmodule FolkDiscordBot.PageTest do
  use ExUnit.Case, async: true

  describe "page_name/1" do
    test "zero-pads the month" do
      assert FolkDiscordBot.page_name(%{timestamp: ~U[2026-01-05 00:00:00Z]}) ==
               "newsletters:2026-01"
    end

    test "handles two-digit months" do
      assert FolkDiscordBot.page_name(%{timestamp: ~U[2026-12-31 23:59:59Z]}) ==
               "newsletters:2026-12"
    end
  end

  describe "render_media/1" do
    test "renders uploaded files and errors" do
      out = FolkDiscordBot.render_media([{:ok, "newsletters:a.png"}, {:skip, "boom"}])
      assert out == "{{newsletters:a.png}}\n[[ERROR|boom]]\n"
    end

    test "empty list renders nothing" do
      assert FolkDiscordBot.render_media([]) == ""
    end
  end

  test "build_wiki_content/1 with no media includes header and text" do
    content =
      FolkDiscordBot.build_wiki_content(%{
        author_name: "dpip",
        timestamp: ~U[2026-10-02 01:56:40Z],
        text: "hello",
        media: []
      })

    assert content =~ "=== dpip | 2026-10-02 01:56:40Z ==="
    assert content =~ "hello"
  end
end
