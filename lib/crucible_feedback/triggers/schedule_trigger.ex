defmodule CrucibleFeedback.Triggers.ScheduleTrigger do
  @moduledoc """
  Trigger retraining on a fixed schedule.
  """

  @doc """
  Return a trigger when the scheduled interval has elapsed.
  """
  @spec check(String.t(), keyword()) :: {:trigger, :scheduled} | nil
  def check(_deployment_id, opts \\ []) do
    interval = interval_seconds(opts)
    now = Keyword.get(opts, :now, DateTime.utc_now())
    last_triggered_at = Keyword.get(opts, :last_triggered_at)

    cond do
      interval == nil ->
        nil

      last_triggered_at == nil ->
        nil

      DateTime.diff(now, last_triggered_at, :second) >= interval ->
        {:trigger, :scheduled}

      true ->
        nil
    end
  end

  defp interval_seconds(opts) do
    config = Application.get_env(:crucible_feedback, :triggers, [])
    Keyword.get(opts, :schedule_interval_seconds, config[:schedule_interval_seconds])
  end
end
