import Config

config :nostrum,
  token: System.fetch_env!("DISCORD_TOKEN"),
  gateway_intents: [:guilds, :guild_message_reactions, :message_content]
