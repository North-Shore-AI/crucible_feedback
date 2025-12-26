defmodule CrucibleFeedback.Quality.RepetitionCheck do
  @moduledoc """
  Detect loops and stuttering in responses.
  """

  @doc """
  Score responses for repetition or stuttering.
  """
  @spec check(map()) :: map()
  def check(event) do
    response = Map.get(event, :response, "")
    words = String.split(response)

    repetition_ratio = calculate_repetition_ratio(words)
    score = max(0.0, 1.0 - repetition_ratio)

    %{
      check: :repetition,
      score: score,
      passed: score >= 0.7,
      details: %{repetition_ratio: repetition_ratio}
    }
  end

  defp calculate_repetition_ratio(words) when length(words) < 10, do: 0.0

  defp calculate_repetition_ratio(words) do
    trigrams = Enum.chunk_every(words, 3, 1, :discard)
    unique = Enum.uniq(trigrams)
    1.0 - length(unique) / max(length(trigrams), 1)
  end
end
