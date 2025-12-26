defmodule CrucibleFeedback.Triggers do
  @moduledoc """
  Decide when to trigger retraining.
  """

  alias CrucibleFeedback.Triggers.{CountTrigger, DriftTrigger, QualityTrigger, ScheduleTrigger}

  @type trigger_result :: {:trigger, atom()}

  @doc """
  Evaluate all configured triggers for a deployment.
  """
  @spec check_triggers(String.t(), keyword()) :: [trigger_result()]
  def check_triggers(deployment_id, opts \\ []) do
    [
      DriftTrigger.check(deployment_id, opts),
      QualityTrigger.check(deployment_id, opts),
      CountTrigger.check(deployment_id, opts),
      ScheduleTrigger.check(deployment_id, opts)
    ]
    |> Enum.filter(&match?({:trigger, _}, &1))
  end
end
