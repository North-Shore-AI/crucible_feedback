import Config

config :crucible_feedback,
  ecto_repos: [CrucibleFeedback.Repo],
  storage: CrucibleFeedback.Storage.Ecto,
  embedding_client: CrucibleFeedback.EmbeddingClient.Noop,
  start_repo: true,
  start_ingestion: true,
  ingestion: [
    flush_interval: :timer.seconds(5),
    max_batch_size: 1_000
  ],
  sanitizer: [
    pii_patterns: []
  ],
  quality: [
    min_length: 20,
    max_length: 4_000
  ],
  triggers: [
    drift_threshold: 0.2,
    quality_threshold: 0.7,
    data_count_threshold: 1_000,
    schedule_interval_seconds: 86_400
  ],
  export: [
    output_dir: "exports"
  ],
  curation: [
    limit: 1_000,
    min_quality_score: 0.8,
    max_hard_quality: 0.5
  ]

config :crucible_feedback, CrucibleFeedback.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "crucible_feedback",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10

import_config "#{config_env()}.exs"
