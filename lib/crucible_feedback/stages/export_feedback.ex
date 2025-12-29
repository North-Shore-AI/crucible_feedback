defmodule CrucibleFeedback.Stages.ExportFeedback do
  @moduledoc """
  Crucible Stage that exports feedback data and stores the path in context.
  """

  @compile {:no_warn_undefined, Crucible.Context}
  @dialyzer {:nowarn_function, run: 2}

  if Code.ensure_loaded?(Crucible.Stage) do
    @behaviour Crucible.Stage
  end

  @impl true
  def describe(_opts) do
    %{
      name: :export_feedback,
      description: "Exports collected feedback data for model retraining",
      required: [],
      optional: [:format, :output_path, :filters],
      types: %{
        format: {:enum, [:jsonl, :parquet, :csv]},
        output_path: :string,
        filters: :map
      }
    }
  end

  @doc """
  Run the export stage and attach the output path to the context.
  """
  @impl true
  @spec run(any(), map()) :: {:ok, any()} | {:error, term()}
  def run(context, opts) do
    deployment_id = Crucible.Context.get_artifact(context, :deployment_id)

    {:ok, export_path} = CrucibleFeedback.export(deployment_id, opts)

    context
    |> Crucible.Context.put_artifact(:feedback_data_path, export_path)
    |> then(&{:ok, &1})
  end
end
