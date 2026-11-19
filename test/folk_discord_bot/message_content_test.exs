defmodule FolkDiscordBot.MessageContentTest do
  use ExUnit.Case, async: true

  alias FolkDiscordBot.MessageContent
  alias Nostrum.Struct.{Emoji, Message, User}
  alias Nostrum.Struct.Message.Reaction

  defp message(reactions) do
    %Message{
      author: %User{username: "dpip"},
      attachments: [],
      content: "hello",
      timestamp: ~U[2026-10-02 01:56:40Z],
      reactions: reactions
    }
  end

  defp reaction(name, me), do: %Reaction{count: 1, me: me, emoji: %Emoji{name: name}}

  describe "process/1" do
    test "is saved when the bot reacted with ✅" do
      reactions = [reaction("📰", false), reaction("✅", true)]
      assert MessageContent.process(message(reactions)).saved
    end

    test "is not saved when only someone else reacted with ✅" do
      reactions = [reaction("✅", false)]
      refute MessageContent.process(message(reactions)).saved
    end

    test "is not saved when the bot reacted with something else" do
      reactions = [reaction("📰", true)]
      refute MessageContent.process(message(reactions)).saved
    end

    test "is not saved when the message has no reactions" do
      refute MessageContent.process(message(nil)).saved
    end
  end
end
