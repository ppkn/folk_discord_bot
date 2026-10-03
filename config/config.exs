import Config

config :nostrum,
  ffmpeg: false,
  streamlink: false,
  youtubedl: false

import_config "#{config_env()}.exs"
