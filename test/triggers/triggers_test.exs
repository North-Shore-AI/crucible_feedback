defmodule CrucibleFeedback.TriggersTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Triggers

  test "aggregates triggers from drift, quality, count, and schedule" do
    now = ~U[2025-01-01 00:00:00Z]
    last = ~U[2024-12-29 00:00:00Z]

    triggers =
      Triggers.check_triggers("deploy-1",
        drift_score: 0.3,
        drift_threshold: 0.2,
        quality_average: 0.6,
        quality_threshold: 0.7,
        event_count: 1_000,
        data_count_threshold: 500,
        now: now,
        last_triggered_at: last,
        schedule_interval_seconds: 86_400
      )

    trigger_types = Enum.map(triggers, fn {:trigger, type} -> type end)

    assert :drift_threshold in trigger_types
    assert :quality_drop in trigger_types
    assert :data_count in trigger_types
    assert :scheduled in trigger_types
  end
end
