defmodule FolkDiscordBot.MessageContentTest do
  use ExUnit.Case, async: true

  alias FolkDiscordBot.MessageContent

  test "returns an error when channel_id/message_id are missing" do
    assert {:error, reason} = MessageContent.fetch_and_process(%{foo: 1})
    assert reason =~ "Need channel_id and message_id"
    assert reason =~ ":foo"
  end
end
