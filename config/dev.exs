import Config

config :logger, :default_formatter,
  format: "\n$time [$level] $message $metadata\n",
  metadata: [:error, :filename, :message_id, :page, :reason, :url]
