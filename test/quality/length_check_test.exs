defmodule CrucibleFeedback.Quality.LengthCheckTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Quality.LengthCheck

  test "passes when response length within bounds" do
    result = LengthCheck.check(%{response: "just right"}, min_length: 3, max_length: 20)

    assert result.passed
    assert result.score == 1.0
  end

  test "flags responses that are too short" do
    result = LengthCheck.check(%{response: "no"}, min_length: 5, max_length: 20)

    refute result.passed
    assert result.details.too_short
    assert result.score < 1.0
  end

  test "flags responses that are too long" do
    long = String.duplicate("a", 30)
    result = LengthCheck.check(%{response: long}, min_length: 5, max_length: 10)

    refute result.passed
    assert result.details.too_long
    assert result.score < 1.0
  end
end
