defmodule CrucibleFeedback.Triggers.DriftTrigger do
  @moduledoc """
  Trigger retraining when drift exceeds a threshold.
  """

  alias CrucibleFeedback.Drift

  @doc """
  Return a drift trigger when the score exceeds threshold.
  """
  @spec check(String.t(), keyword()) :: {:trigger, :drift_threshold} | nil
  def check(deployment_id, opts \\ []) do
    score = Keyword.get(opts, :drift_score) || Drift.current_score(deployment_id, opts)
    threshold = threshold(opts)

    if score > threshold do
      {:trigger, :drift_threshold}
    end
  end

  defp threshold(opts) do
    config = Application.get_env(:crucible_feedback, :triggers, [])
    Keyword.get(opts, :drift_threshold, config[:drift_threshold] || 0.2)
  end
end
