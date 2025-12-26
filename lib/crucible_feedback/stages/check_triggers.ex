defmodule CrucibleFeedback.Stages.CheckTriggers do
  @moduledoc """
  Crucible Stage that checks retraining triggers and stores results in context.
  """

  @compile {:no_warn_undefined, Crucible.Context}
  @dialyzer {:nowarn_function, run: 2}

  if Code.ensure_loaded?(Crucible.Stage) do
    @behaviour Crucible.Stage
  end

  @doc """
  Run trigger checks and attach results to the context.
  """
  @spec run(any(), map()) :: {:ok, any()} | {:error, term()}
  def run(context, opts) do
    deployment_id = Crucible.Context.get_artifact(context, :deployment_id)

    triggers = CrucibleFeedback.check_triggers(deployment_id, opts)

    context
    |> Crucible.Context.put_artifact(:retrain_triggers, triggers)
    |> Crucible.Context.merge_metrics(%{trigger_count: length(triggers)})
    |> then(&{:ok, &1})
  end
end
