defmodule CrucibleFeedback.Curation.HardExamples do
  @moduledoc """
  Select difficult examples for retraining.
  """

  @doc """
  Select low-quality or negatively signaled events.
  """
  @spec select([map()], keyword()) :: [map()]
  def select(events, opts \\ []) do
    max_quality_score =
      Keyword.get(opts, :max_quality_score, curation_config(:max_hard_quality, 0.5))

    limit = Keyword.get(opts, :limit, 100)

    events
    |> Enum.filter(&hard_example?(&1, max_quality_score))
    |> Enum.sort_by(&difficulty_score/1, :desc)
    |> Enum.take(limit)
    |> Enum.map(&to_curated_example(&1, :hard_example, difficulty_score(&1)))
  end

  defp hard_example?(event, max_quality_score) do
    signals = Map.get(event, :signals, []) || []
    score = event.quality_score || 0.0

    score <= max_quality_score or
      Enum.any?(signals, &(&1.signal_type in [:thumbs_down, :regenerate, :report]))
  end

  defp difficulty_score(event) do
    base = 1.0 - (event.quality_score || 0.0)
    signals = Map.get(event, :signals, []) || []

    base + signal_penalty(signals)
  end

  defp signal_penalty(signals) do
    Enum.reduce(signals, 0.0, fn signal, acc ->
      acc +
        case signal.signal_type do
          :thumbs_down -> 2.0
          :regenerate -> 1.5
          :report -> 2.5
          _ -> 0.0
        end
    end)
  end

  defp to_curated_example(event, source, score) do
    %{
      inference_event_id: event.id,
      deployment_id: event.deployment_id,
      curation_source: source,
      curation_score: score,
      prompt: event.prompt,
      response: event.response
    }
  end

  defp curation_config(key, default) do
    Application.get_env(:crucible_feedback, :curation, []) |> Keyword.get(key, default)
  end
end
