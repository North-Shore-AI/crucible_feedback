defmodule CrucibleFeedback.Export.HuggingFace do
  @moduledoc """
  Export curated examples in a HuggingFace-style dataset directory.
  """

  @doc """
  Write a HuggingFace-style dataset directory.
  """
  @spec export([map()], Path.t()) :: {:ok, Path.t()} | {:error, term()}
  def export(examples, output_dir) do
    data_path = Path.join(output_dir, "data.jsonl")
    info_path = Path.join(output_dir, "dataset_info.json")

    lines =
      Enum.map(examples, fn example ->
        Jason.encode!(%{
          prompt: example.prompt,
          response: example.response,
          source: example.curation_source,
          score: example.curation_score
        })
      end)

    info = %{
      description: "CrucibleFeedback curated dataset",
      features: %{
        prompt: %{dtype: "string"},
        response: %{dtype: "string"},
        source: %{dtype: "string"},
        score: %{dtype: "float"}
      }
    }

    with :ok <- File.mkdir_p(output_dir),
         :ok <- File.write(data_path, Enum.join(lines, "\n")),
         :ok <- File.write(info_path, Jason.encode!(info, pretty: true)) do
      {:ok, output_dir}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
