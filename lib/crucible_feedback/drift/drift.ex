defmodule CrucibleFeedback.Drift do
  @moduledoc """
  Detect distribution shift in inputs and outputs.
  """

  alias CrucibleFeedback.Drift.{Embedding, Output, Statistical}

  @type drift_result :: %{
          type: atom(),
          score: float(),
          drifted: boolean(),
          details: map()
        }

  @doc """
  Detect drift for a deployment by comparing recent and baseline windows.
  """
  @spec detect(String.t(), keyword()) :: [drift_result()]
  def detect(deployment_id, opts \\ []) do
    window_size = Keyword.get(opts, :window_size, 1_000)
    storage = Keyword.get(opts, :storage, Application.get_env(:crucible_feedback, :storage))

    {window_a, window_b} = get_comparison_windows(storage, deployment_id, window_size)

    [
      Statistical.detect(window_a, window_b, opts),
      Embedding.detect(window_a, window_b, opts),
      Output.detect(window_a, window_b, opts)
    ]
  end

  @doc """
  Return the maximum drift score across detectors.
  """
  @spec current_score(String.t(), keyword()) :: float()
  def current_score(deployment_id, opts \\ []) do
    detect(deployment_id, opts)
    |> Enum.map(& &1.score)
    |> Enum.max(fn -> 0.0 end)
  end

  defp get_comparison_windows(storage, deployment_id, size) do
    events = storage.list_events(deployment_id, limit: size * 2, order: :desc)
    {recent, baseline} = Enum.split(events, size)
    {recent, baseline}
  end
end
