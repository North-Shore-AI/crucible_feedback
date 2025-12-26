defmodule CrucibleFeedback.Drift.OutputTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Drift.Output

  test "detects output drift from quality and length changes" do
    window_a = Enum.map(1..20, fn _ -> %{response: "short", quality_score: 0.95} end)

    window_b =
      Enum.map(1..20, fn _ -> %{response: String.duplicate("l", 200), quality_score: 0.2} end)

    result = Output.detect(window_a, window_b, quality_threshold: 0.3, length_threshold: 0.3)

    assert result.type == :output
    assert result.drifted
    assert result.score > 0.3
  end
end
