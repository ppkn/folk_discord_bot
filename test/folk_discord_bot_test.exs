defmodule FolkDiscordBotTest do
  use ExUnit.Case
  doctest FolkDiscordBot

  test "greets the world" do
    assert FolkDiscordBot.hello() == :world
  end
end
