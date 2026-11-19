import Config

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

config :nostrum,
  ffmpeg: false,
  streamlink: false,
  youtubedl: false

config :logger, :default_formatter,
  metadata: [:byte_count, :error, :filename, :message_id, :page, :reason, :url]

import_config "#{config_env()}.exs"
