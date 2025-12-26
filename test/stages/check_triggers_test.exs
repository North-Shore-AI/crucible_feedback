defmodule CrucibleFeedback.Stages.CheckTriggersTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Stages.CheckTriggers

  test "stores trigger results in context" do
    context = %Crucible.Context{
      experiment_id: "test",
      run_id: "test",
      experiment: nil,
      artifacts: %{deployment_id: "d1"}
    }

    {:ok, updated} =
      CheckTriggers.run(context,
        drift_score: 0.3,
        drift_threshold: 0.2,
        quality_average: 0.6,
        quality_threshold: 0.7,
        event_count: 1_000,
        data_count_threshold: 500,
        now: ~U[2025-01-01 00:00:00Z],
        last_triggered_at: ~U[2024-12-29 00:00:00Z],
        schedule_interval_seconds: 86_400,
        storage: CrucibleFeedback.Storage.Memory
      )

    triggers = Crucible.Context.get_artifact(updated, :retrain_triggers)
    refute Enum.empty?(triggers)
    assert Map.get(updated.metrics, :trigger_count) == Enum.count(triggers)
  end
end
