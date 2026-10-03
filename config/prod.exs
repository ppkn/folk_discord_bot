import Config

config :logger, level: :info

config :logger, :default_formatter, format: "[$level] $message $metadata\n"
