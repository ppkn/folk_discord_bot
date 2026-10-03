defmodule FolkDiscordBot.Member do
  @moduledoc """
  Checks Discord guild members' roles by name.
  """

  alias Nostrum.Struct.Guild

  @spec has_role?(Guild.Member.t(), Guild.t(), String.t()) :: boolean()
  def has_role?(member, guild, role_name) do
    Enum.any?(member.roles, fn role_id ->
      match?(%{name: ^role_name}, guild.roles[role_id])
    end)
  end
end
