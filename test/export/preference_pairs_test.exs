defmodule CrucibleFeedback.Export.PreferencePairsTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Export.PreferencePairs

  test "exports preference pairs from edit signals" do
    events = [
      %{prompt: "p1", response: "r1", signals: [%{signal_type: :edit, edited_response: "better"}]}
    ]

    path = Path.join(System.tmp_dir!(), "crucible_feedback_pairs.jsonl")

    {:ok, ^path} = PreferencePairs.export(events, path)

    contents = File.read!(path)
    assert contents =~ "\"chosen\""
    assert contents =~ "\"rejected\""
  end
end
