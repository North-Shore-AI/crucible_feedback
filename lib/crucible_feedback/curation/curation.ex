defmodule CrucibleFeedback.Curation do
  @moduledoc """
  Select valuable examples for retraining.
  """

  alias CrucibleFeedback.Curation.{Diverse, HardExamples, HighQuality}

  @doc """
  Curate examples for a deployment.
  """
  @spec curate(String.t(), keyword()) :: [map()]
  def curate(deployment_id, opts \\ []) do
    storage = Keyword.get(opts, :storage, Application.get_env(:crucible_feedback, :storage))

    limit =
      Keyword.get(
        opts,
        :limit,
        Application.get_env(:crucible_feedback, :curation, [])[:limit] || 1_000
      )

    persist = Keyword.get(opts, :persist, false)

    events =
      Keyword.get(opts, :events) || storage.list_events(deployment_id, include_signals: true)

    user_edits = user_edit_examples(events)
    high_quality = HighQuality.select(events, Keyword.merge(opts, limit: div(limit, 3)))
    hard = HardExamples.select(events, Keyword.merge(opts, limit: div(limit, 3)))
    diverse = Diverse.select(events, Keyword.merge(opts, limit: div(limit, 3)))

    curated = merge_and_dedupe([user_edits, high_quality, hard, diverse])

    if persist do
      storage.insert_curated_examples(curated)
    end

    :telemetry.execute(
      [:crucible_feedback, :curation, :run],
      %{count: length(curated)},
      %{deployment_id: deployment_id}
    )

    curated
  end

  defp merge_and_dedupe(selections) do
    selections
    |> List.flatten()
    |> Enum.uniq_by(& &1.inference_event_id)
  end

  defp user_edit_examples(events) do
    events
    |> Enum.filter(&has_edit_signal?/1)
    |> Enum.map(&to_user_edit_example/1)
  end

  defp has_edit_signal?(event) do
    signals = Map.get(event, :signals, []) || []
    Enum.any?(signals, &(&1.signal_type == :edit))
  end

  defp to_user_edit_example(event) do
    edit_signal = event.signals |> Enum.find(&(&1.signal_type == :edit))
    response = (edit_signal && edit_signal.edited_response) || event.response

    %{
      inference_event_id: event.id,
      deployment_id: event.deployment_id,
      curation_source: :user_edit,
      curation_score: 10.0,
      prompt: event.prompt,
      response: response
    }
  end
end
