defmodule CrucibleFeedback.Export.Parquet do
  @moduledoc """
  Export curated examples to a Parquet-like file.

  This implementation writes JSONL content to the requested path as a
  lightweight placeholder until a Parquet writer is integrated.
  """

  @doc """
  Write curated examples to a Parquet-like file.
  """
  @spec export([map()], Path.t()) :: {:ok, Path.t()} | {:error, term()}
  def export(examples, output_path) do
    lines =
      Enum.map(examples, fn example ->
        Jason.encode!(%{
          prompt: example.prompt,
          response: example.response,
          source: example.curation_source,
          score: example.curation_score
        })
      end)

    with :ok <- File.mkdir_p(Path.dirname(output_path)),
         :ok <- File.write(output_path, Enum.join(lines, "\n")) do
      {:ok, output_path}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
