defmodule CrucibleFeedback.Export.PreferencePairs do
  @moduledoc """
  Export preference pairs from user edits for DPO training.
  """

  @doc """
  Write preference pairs derived from edit signals.
  """
  @spec export([map()], Path.t()) :: {:ok, Path.t()} | {:error, term()}
  def export(events_with_edits, output_path) do
    pairs =
      events_with_edits
      |> Enum.map(&build_pair/1)
      |> Enum.filter(& &1)
      |> Enum.map(&Jason.encode!/1)

    with :ok <- File.mkdir_p(Path.dirname(output_path)),
         :ok <- File.write(output_path, Enum.join(pairs, "\n")) do
      {:ok, output_path}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp build_pair(event) do
    edit_signal =
      event
      |> Map.get(:signals, [])
      |> Enum.find(&(&1.signal_type == :edit))

    if edit_signal && edit_signal.edited_response do
      %{
        prompt: event.prompt,
        chosen: edit_signal.edited_response,
        rejected: event.response
      }
    end
  end
end
