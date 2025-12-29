defmodule CrucibleFeedback.Stages.CheckTriggers do
  @moduledoc """
  Crucible Stage that checks retraining triggers and stores results in context.
  """

  @compile {:no_warn_undefined, Crucible.Context}
  @dialyzer {:nowarn_function, run: 2}

  if Code.ensure_loaded?(Crucible.Stage) do
    @behaviour Crucible.Stage
  end

  @impl true
  def describe(_opts) do
    %{
      name: :check_triggers,
      description: "Checks retraining triggers based on feedback signals and drift detection",
      required: [],
      optional: [:threshold, :window_hours, :trigger_types],
      types: %{
        threshold: :float,
        window_hours: :integer,
        trigger_types: {:list, {:enum, [:drift, :accuracy, :volume, :feedback]}}
      }
    }
  end

  @doc """
  Run trigger checks and attach results to the context.
  """
  @impl true
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
