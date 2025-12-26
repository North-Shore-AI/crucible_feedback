defmodule CrucibleFeedback.Triggers.CountTrigger do
  @moduledoc """
  Trigger retraining when enough data has been collected.
  """

  @doc """
  Return a trigger when event count meets threshold.
  """
  @spec check(String.t(), keyword()) :: {:trigger, :data_count} | nil
  def check(deployment_id, opts \\ []) do
    storage = Keyword.get(opts, :storage, Application.get_env(:crucible_feedback, :storage))
    count = Keyword.get(opts, :event_count) || storage.count_events(deployment_id, opts)
    threshold = threshold(opts)

    if count >= threshold do
      {:trigger, :data_count}
    end
  end

  defp threshold(opts) do
    config = Application.get_env(:crucible_feedback, :triggers, [])
    Keyword.get(opts, :data_count_threshold, config[:data_count_threshold] || 1_000)
  end
end
