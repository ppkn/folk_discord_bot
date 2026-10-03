defmodule FolkDiscordBot.Consumer do
  use Nostrum.Consumer

  def handle_event({:MESSAGE_REACTION_ADD, msg, _ws_state}) do
    FolkDiscordBot.handle_message_reaction(msg)
  end
end
