defmodule CrucibleFeedback.Quality.RefusalCheck do
  @moduledoc """
  Detect unwanted refusals in responses.
  """

  @doc """
  Score responses for refusal language.
  """
  @spec check(map()) :: map()
  def check(event) do
    response = Map.get(event, :response, "")

    patterns =
      Application.get_env(:crucible_feedback, :quality, [])
      |> Keyword.get(:refusal_patterns, default_patterns())

    has_refusal = Enum.any?(patterns, &Regex.match?(&1, response))

    score = if has_refusal, do: 0.3, else: 1.0

    %{
      check: :refusal,
      score: score,
      passed: not has_refusal,
      details: %{has_refusal: has_refusal}
    }
  end

  defp default_patterns do
    [
      ~r/I cannot|I can't|I'm unable to/i,
      ~r/I apologize, but/i,
      ~r/As an AI/i,
      ~r/I don't have the ability/i
    ]
  end
end
