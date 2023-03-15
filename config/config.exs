import Config

config :logger, Kvasir.Logger,
  rfc: :rfc5424,
  host: "localhost",
  port: 5544,
  app_name: "kvasir-dev",
  facility: :user
