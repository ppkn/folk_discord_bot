defmodule FolkDiscordBot.Member do
  def has_role?(member, guild_id, role_name) do
    guild = Nostrum.Cache.GuildCache.get!(guild_id)
    has_role_in?(member, guild.roles, role_name)
  end

  @doc false
  def has_role_in?(member, guild_roles, role_name) do
    Enum.any?(member.roles, fn role_id ->
      match?(%{name: ^role_name}, guild_roles[role_id])
    end)
  end
end
