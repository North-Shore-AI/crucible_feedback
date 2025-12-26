defmodule CrucibleFeedback.Drift.StatisticalTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Drift.Statistical

  defp event_with_prompt(prompt), do: %{prompt: prompt}

  test "detects drift for divergent prompt length distributions" do
    window_a = Enum.map(1..50, fn _ -> event_with_prompt("short") end)
    window_b = Enum.map(1..50, fn _ -> event_with_prompt(String.duplicate("l", 200)) end)

    result = Statistical.detect(window_a, window_b)

    assert result.type == :statistical
    assert result.drifted
    assert result.score > 0.1
  end

  test "does not flag drift for similar distributions" do
    window_a = Enum.map(1..50, fn _ -> event_with_prompt("medium length") end)
    window_b = Enum.map(1..50, fn _ -> event_with_prompt("medium length") end)

    result = Statistical.detect(window_a, window_b)

    refute result.drifted
    assert result.score <= 0.1
  end
end
