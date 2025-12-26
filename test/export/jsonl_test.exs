defmodule CrucibleFeedback.Export.JSONLTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Export.JSONL

  test "exports JSONL with curated examples" do
    examples = [
      %{prompt: "p1", response: "r1", curation_source: :high_quality, curation_score: 1.2},
      %{prompt: "p2", response: "r2", curation_source: :diverse, curation_score: 0.8}
    ]

    path = Path.join(System.tmp_dir!(), "crucible_feedback_test.jsonl")

    {:ok, ^path} = JSONL.export(examples, path)

    contents = File.read!(path)
    lines = String.split(contents, "\n", trim: true)

    assert length(lines) == 2
    assert Enum.all?(lines, &String.contains?(&1, "\"prompt\""))
  end
end
