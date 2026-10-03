import Config

config :nostrum,
  youtubedl: false,
  streamlink: false

import_config "#{config_env()}.exs"
