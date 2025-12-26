# CrucibleFeedback

<p align="center">
  <img src="assets/crucible_feedback.svg" alt="CrucibleFeedback Logo" width="200"/>
</p>

<p align="center">
  <strong>Production feedback loop for ML systems: telemetry ingestion, quality assessment, drift detection, curation, retraining triggers, and export</strong>
</p>

<p align="center">
  <a href="https://hex.pm/packages/crucible_feedback"><img src="https://img.shields.io/hexpm/v/crucible_feedback.svg" alt="Hex Version"/></a>
  <a href="https://hexdocs.pm/crucible_feedback"><img src="https://img.shields.io/badge/hex-docs-blue.svg" alt="Hex Docs"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License"/></a>
</p>

---

## Features

- Batch-buffered ingestion with PII sanitization and telemetry events
- User signal capture (thumbs up/down, regenerate, edit, copy, share, report)
- Multi-check quality assessment (format, length, refusal, repetition, optional LLM-judge)
- Drift detection (statistical, embedding, output)
- Data curation strategies (high-quality, hard examples, diverse)
- Retraining triggers (drift, quality drop, count, schedule)
- Export to JSONL, HuggingFace dataset dir, Parquet placeholder, preference pairs
- Crucible stage integration for pipelines

## Installation

```elixir
# mix.exs
{:crucible_feedback, "~> 0.1.0"}
```

## Configuration

```elixir
# config/config.exs
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
```

## Usage

### Ingest Events

```elixir
CrucibleFeedback.log_inference(%{
  deployment_id: "deploy-1",
  model_version_id: "model-1",
  user_id: "user-123",
  prompt: "What is 2+2?",
  response: "4",
  latency_ms: 120,
  token_count: 42,
  metadata: %{source: "api"}
})
```

### Record Signals

```elixir
CrucibleFeedback.record_signal("inference-id", :thumbs_up, %{source: "ui"})
CrucibleFeedback.record_user_edit("inference-id", "User edited response")
```

### Quality Assessment

```elixir
CrucibleFeedback.assess_quality(%{response: "{\"ok\": true}"})
CrucibleFeedback.get_quality_stats("deploy-1")
```

### Drift Detection

```elixir
CrucibleFeedback.detect_drift("deploy-1", window_size: 1_000)
```

### Curation and Export

```elixir
CrucibleFeedback.curate("deploy-1", persist: true)
CrucibleFeedback.export("deploy-1", format: :jsonl, output_path: "exports/feedback.jsonl")
CrucibleFeedback.export_preference_pairs("deploy-1")
```

### Retraining Triggers

```elixir
CrucibleFeedback.check_triggers("deploy-1")
```

### Crucible Stages

```elixir
CrucibleFeedback.Stages.ExportFeedback.run(context, format: :jsonl)
CrucibleFeedback.Stages.CheckTriggers.run(context, [])
```

## Storage Backends

- `CrucibleFeedback.Storage.Ecto` (Postgres)
- `CrucibleFeedback.Storage.Memory` (tests/dev)
- `CrucibleFeedback.Storage.Clickhouse` (placeholder)

## Migrations

```bash
mix ecto.create
mix ecto.migrate
```

## Testing

```bash
mix test
```

## Notes

- Parquet export currently writes JSONL content to the specified `.parquet` path as a placeholder.
- To enable embedding drift and diversity selection, configure `embedding_client` with a real provider.
