defmodule CrucibleFeedback.Export do
  @moduledoc """
  Export curated data for training.
  """

  alias CrucibleFeedback.Export.{HuggingFace, JSONL, Parquet, PreferencePairs}

  @doc """
  Export curated examples in the requested format.
  """
  @spec export(String.t(), keyword()) :: {:ok, Path.t()} | {:error, term()}
  def export(deployment_id, opts \\ []) do
    format = Keyword.get(opts, :format, :jsonl)
    output_path = Keyword.get(opts, :output_path, generate_output_path(format))
    storage = Keyword.get(opts, :storage, Application.get_env(:crucible_feedback, :storage))
    include_exported = Keyword.get(opts, :include_exported, false)

    curated =
      storage.list_curated_examples(deployment_id,
        exported: include_exported,
        limit: opts[:limit]
      )

    export_batch_id = Keyword.get(opts, :export_batch_id, Ecto.UUID.generate())

    result =
      case format do
        :jsonl -> JSONL.export(curated, output_path)
        :huggingface -> HuggingFace.export(curated, output_path)
        :parquet -> Parquet.export(curated, output_path)
      end

    case result do
      {:ok, path} ->
        ids = Enum.map(curated, & &1.id) |> Enum.filter(& &1)
        :ok = storage.mark_curated_exported(ids, export_batch_id)

        :telemetry.execute(
          [:crucible_feedback, :export, :complete],
          %{count: length(curated)},
          %{format: format, output_path: path}
        )

        {:ok, path}

      error ->
        error
    end
  end

  @doc """
  Export preference pairs derived from user edit signals.
  """
  @spec export_preference_pairs(String.t(), keyword()) :: {:ok, Path.t()} | {:error, term()}
  def export_preference_pairs(deployment_id, opts \\ []) do
    output_path = Keyword.get(opts, :output_path, generate_output_path(:preference))
    storage = Keyword.get(opts, :storage, Application.get_env(:crucible_feedback, :storage))

    events_with_edits = storage.list_events_with_edits(deployment_id, opts)
    PreferencePairs.export(events_with_edits, output_path)
  end

  defp generate_output_path(format) do
    dir =
      Application.get_env(:crucible_feedback, :export, []) |> Keyword.get(:output_dir, "exports")

    File.mkdir_p!(dir)

    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    ext = extension_for(format)

    Path.join(dir, "feedback_#{timestamp}#{ext}")
  end

  defp extension_for(:jsonl), do: ".jsonl"
  defp extension_for(:huggingface), do: ""
  defp extension_for(:parquet), do: ".parquet"
  defp extension_for(:preference), do: "_preferences.jsonl"
end
