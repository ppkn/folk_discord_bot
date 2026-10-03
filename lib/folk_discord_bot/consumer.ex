defmodule FolkDiscordBot.Consumer do
  @moduledoc """
  Receives Discord gateway events from Nostrum and forwards reactions to
  `FolkDiscordBot.handle_message_reaction/1`.
  """

  use Nostrum.Consumer

  @impl true
  def handle_event({:MESSAGE_REACTION_ADD, event, _ws_state}) do
    FolkDiscordBot.handle_message_reaction(event)
  end
end
