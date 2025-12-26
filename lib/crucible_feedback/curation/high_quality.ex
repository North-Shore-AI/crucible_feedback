defmodule CrucibleFeedback.Curation.HighQuality do
  @moduledoc """
  Select high-quality examples.
  """

  @doc """
  Select high-quality events with positive signals.
  """
  @spec select([map()], keyword()) :: [map()]
  def select(events, opts \\ []) do
    min_quality_score =
      Keyword.get(opts, :min_quality_score, curation_config(:min_quality_score, 0.8))

    limit = Keyword.get(opts, :limit, 100)

    events
    |> Enum.filter(fn event ->
      event.quality_score &&
        event.quality_score >= min_quality_score &&
        has_positive_signals?(event)
    end)
    |> Enum.sort_by(&compute_score/1, :desc)
    |> Enum.take(limit)
    |> Enum.map(&to_curated_example(&1, :high_quality, compute_score(&1)))
  end

  defp has_positive_signals?(event) do
    signals = Map.get(event, :signals, []) || []
    Enum.any?(signals, &(&1.signal_type in [:thumbs_up, :copy, :share, :edit]))
  end

  defp compute_score(event) do
    base = event.quality_score || 0.0
    signals = Map.get(event, :signals, []) || []
    base + signal_boost(signals)
  end

  defp signal_boost(signals) do
    Enum.reduce(signals, 0, fn signal, acc ->
      acc +
        case signal.signal_type do
          :thumbs_up -> 3
          :copy -> 2
          :share -> 2
          :edit -> 5
          :thumbs_down -> -2
          _ -> 0
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
