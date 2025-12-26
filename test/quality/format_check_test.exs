defmodule CrucibleFeedback.Quality.FormatCheckTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Quality.FormatCheck

  test "detects valid JSON responses" do
    result = FormatCheck.check(%{response: "{\"ok\": true}"})

    assert result.check == :format
    assert result.details.format == :json
    assert result.score == 1.0
    assert result.passed
  end

  test "detects balanced markdown code blocks" do
    response = """
    ```elixir
    IO.puts(\"ok\")
    ```
    """

    result = FormatCheck.check(%{response: response})

    assert result.details.format == :markdown
    assert result.score >= 0.9
  end

  test "falls back to plain format" do
    result = FormatCheck.check(%{response: "just text"})

    assert result.details.format == :plain
    assert result.score == 0.7
  end
end
