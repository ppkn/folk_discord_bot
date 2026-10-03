defmodule FolkDiscordBot.Member do
  @moduledoc """
  Checks Discord guild members' roles by name.
  """

  alias Nostrum.Cache.GuildCache

  def has_role?(member, guild_id, role_name) do
    guild = GuildCache.get!(guild_id)
    has_role_in?(member, guild.roles, role_name)
  end

  def has_role_in?(member, guild_roles, role_name) do
    Enum.any?(member.roles, fn role_id ->
      match?(%{name: ^role_name}, guild_roles[role_id])
    end)
  end
end
