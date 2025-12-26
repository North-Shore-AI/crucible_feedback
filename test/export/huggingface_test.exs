defmodule CrucibleFeedback.Export.HuggingFaceTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Export.HuggingFace

  test "exports HuggingFace-style dataset directory" do
    examples = [
      %{prompt: "p1", response: "r1", curation_source: :high_quality, curation_score: 1.2}
    ]

    dir = Path.join(System.tmp_dir!(), "crucible_feedback_hf")

    {:ok, ^dir} = HuggingFace.export(examples, dir)

    assert File.exists?(Path.join(dir, "data.jsonl"))
    assert File.exists?(Path.join(dir, "dataset_info.json"))
  end
end
