defmodule FolkDiscordBot.Member do
  def has_role?(member, guild_id, role_name) do
    role_name in role_names(guild_id, member.roles)
  end

  defp role_names(guild_id, role_ids) do
    role_ids
    |> Enum.map(fn role_id ->
      guild = Nostrum.Cache.GuildCache.get!(guild_id)
      guild.roles[role_id].name
    end)
  end
end
