defmodule CrucibleFeedback.Drift.Output do
  @moduledoc """
  Output drift detection based on quality and response length.
  """

  @doc """
  Compute output drift based on quality and response length shifts.
  """
  @spec detect([map()], [map()], keyword()) :: map()
  def detect(window_a, window_b, opts \\ []) do
    length_a = avg_response_length(window_a)
    length_b = avg_response_length(window_b)

    quality_a = avg_quality(window_a)
    quality_b = avg_quality(window_b)

    length_change = relative_change(length_a, length_b)
    quality_change = abs(quality_a - quality_b)

    length_threshold = Keyword.get(opts, :length_threshold, 0.2)
    quality_threshold = Keyword.get(opts, :quality_threshold, 0.2)

    drifted = length_change > length_threshold or quality_change > quality_threshold
    score = max(length_change, quality_change)

    %{
      type: :output,
      score: score,
      drifted: drifted,
      details: %{
        length_change: length_change,
        quality_change: quality_change,
        avg_length_a: length_a,
        avg_length_b: length_b,
        avg_quality_a: quality_a,
        avg_quality_b: quality_b
      }
    }
  end

  defp avg_response_length(events) do
    lengths = Enum.map(events, &String.length(Map.get(&1, :response, "")))

    case lengths do
      [] -> 0.0
      _ -> Enum.sum(lengths) / length(lengths)
    end
  end

  defp avg_quality(events) do
    scores = Enum.map(events, &(Map.get(&1, :quality_score, 0.0) || 0.0))

    case scores do
      [] -> 0.0
      _ -> Enum.sum(scores) / length(scores)
    end
  end

  defp relative_change(a, b) do
    denominator = max(max(a, b), 1.0)
    abs(a - b) / denominator
  end
end
