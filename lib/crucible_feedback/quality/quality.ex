defmodule CrucibleFeedback.Quality do
  @moduledoc """
  Assess response quality using multiple checks.
  """

  alias CrucibleFeedback.Quality.{
    FormatCheck,
    LengthCheck,
    LLMJudge,
    RefusalCheck,
    RepetitionCheck
  }

  @type check_result :: %{
          check: atom(),
          score: float(),
          passed: boolean(),
          details: map()
        }

  @doc """
  Assess quality for an inference event.
  """
  @spec assess(map(), keyword()) :: %{score: float(), checks: [check_result()]}
  def assess(event, opts \\ []) do
    checks =
      [
        FormatCheck.check(event),
        LengthCheck.check(event, opts),
        RefusalCheck.check(event),
        RepetitionCheck.check(event)
      ]
      |> maybe_add_llm_judge(event, opts)

    score = aggregate_score(checks)

    :telemetry.execute(
      [:crucible_feedback, :quality, :assess],
      %{score: score},
      %{check_count: length(checks)}
    )

    %{score: score, checks: checks}
  end

  @doc """
  Compute a rolling average quality score for a deployment.
  """
  @spec rolling_average(String.t(), keyword()) :: float()
  def rolling_average(deployment_id, opts \\ []) do
    storage = Keyword.get(opts, :storage, Application.get_env(:crucible_feedback, :storage))
    window_size = Keyword.get(opts, :window_size, 1_000)

    scores =
      storage.list_events(deployment_id, limit: window_size)
      |> Enum.map(&(&1.quality_score || 0.0))

    case scores do
      [] -> 1.0
      _ -> Enum.sum(scores) / length(scores)
    end
  end

  defp maybe_add_llm_judge(checks, event, opts) do
    if Keyword.get(opts, :llm_judge, false) do
      checks ++ [LLMJudge.check(event, opts)]
    else
      checks
    end
  end

  defp aggregate_score(checks) do
    total = Enum.reduce(checks, 0.0, fn check, acc -> acc + check.score end)
    total / max(length(checks), 1)
  end
end
