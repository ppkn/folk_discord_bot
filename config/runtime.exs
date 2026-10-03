import Config

if config_env() != :test do
  config :nostrum,
    token: System.fetch_env!("DISCORD_TOKEN"),
    gateway_intents: [:guilds, :guild_message_reactions, :message_content]
end

config :folk_discord_bot, :dokuwiki,
  base_url: System.get_env("DOKUWIKI_URL"),
  token: System.get_env("DOKUWIKI_TOKEN")
