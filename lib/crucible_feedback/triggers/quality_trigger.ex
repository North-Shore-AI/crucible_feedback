defmodule CrucibleFeedback.Triggers.QualityTrigger do
  @moduledoc """
  Trigger retraining when average quality drops below threshold.
  """

  alias CrucibleFeedback.Quality

  @doc """
  Return a trigger when rolling quality drops below threshold.
  """
  @spec check(String.t(), keyword()) :: {:trigger, :quality_drop} | nil
  def check(deployment_id, opts \\ []) do
    avg = Keyword.get(opts, :quality_average) || Quality.rolling_average(deployment_id, opts)
    threshold = threshold(opts)

    if avg < threshold do
      {:trigger, :quality_drop}
    end
  end

  defp threshold(opts) do
    config = Application.get_env(:crucible_feedback, :triggers, [])
    Keyword.get(opts, :quality_threshold, config[:quality_threshold] || 0.7)
  end
end
