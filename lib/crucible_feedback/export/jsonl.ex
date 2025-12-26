defmodule CrucibleFeedback.Export.JSONL do
  @moduledoc """
  Export curated examples to JSONL format.
  """

  @doc """
  Write curated examples as JSONL lines.
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
