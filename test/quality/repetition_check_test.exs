defmodule CrucibleFeedback.Quality.RepetitionCheckTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Quality.RepetitionCheck

  test "penalizes repeated sequences" do
    response = "one two three one two three one two three one two three"
    result = RepetitionCheck.check(%{response: response})

    refute result.passed
    assert result.details.repetition_ratio > 0.2
  end

  test "ignores short responses" do
    result = RepetitionCheck.check(%{response: "short response"})

    assert result.passed
    assert result.details.repetition_ratio == 0.0
  end
end
