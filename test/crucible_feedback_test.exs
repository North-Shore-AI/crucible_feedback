defmodule CrucibleFeedbackTest do
  use ExUnit.Case, async: true

  test "assesses quality via public API" do
    result = CrucibleFeedback.assess_quality(%{response: "ok"})

    assert is_float(result.score)
    assert is_list(result.checks)
  end
end
