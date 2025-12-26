import Config

config :crucible_feedback,
  start_repo: false,
  start_ingestion: false,
  storage: CrucibleFeedback.Storage.Memory

# Configure repo from crucible_framework dependency to prevent connection errors
config :crucible_framework, CrucibleFramework.Repo,
  database: "crucible_framework_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 1
