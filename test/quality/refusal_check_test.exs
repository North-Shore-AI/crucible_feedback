defmodule CrucibleFeedback.Quality.RefusalCheckTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Quality.RefusalCheck

  test "detects refusal language" do
    result = RefusalCheck.check(%{response: "I cannot help with that."})

    refute result.passed
    assert result.details.has_refusal
    assert result.score < 1.0
  end

  test "passes normal responses" do
    result = RefusalCheck.check(%{response: "Sure, here is the answer."})

    assert result.passed
    assert result.score == 1.0
  end
end
