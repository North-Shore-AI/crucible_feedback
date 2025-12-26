defmodule CrucibleFeedback.Stages.ExportFeedbackTest do
  use ExUnit.Case, async: true

  import Mox

  alias CrucibleFeedback.Stages.ExportFeedback
  alias CrucibleFeedback.Storage.Mock, as: StorageMock

  setup :set_mox_from_context
  setup :verify_on_exit!

  test "exports feedback data and stores path in context" do
    curated = [
      %{id: "c1", prompt: "p", response: "r", curation_source: :high_quality, curation_score: 1.0}
    ]

    StorageMock
    |> expect(:list_curated_examples, fn "d1", _opts -> curated end)
    |> expect(:mark_curated_exported, fn ["c1"], _batch_id -> :ok end)

    context = %Crucible.Context{
      experiment_id: "test",
      run_id: "test",
      experiment: nil,
      artifacts: %{deployment_id: "d1"}
    }

    path = Path.join(System.tmp_dir!(), "crucible_feedback_stage.jsonl")

    {:ok, updated} =
      ExportFeedback.run(context, format: :jsonl, output_path: path, storage: StorageMock)

    assert Crucible.Context.get_artifact(updated, :feedback_data_path) == path
  end
end
