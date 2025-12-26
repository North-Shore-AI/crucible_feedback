defmodule CrucibleFeedback.Quality.LLMJudge do
  @moduledoc """
  Optional LLM-as-judge check.
  """

  @doc """
  Run the LLM judge (if configured) and return a check result.
  """
  @spec check(map(), keyword()) :: map()
  def check(event, opts \\ []) do
    judge = Keyword.get(opts, :llm_judge) || Application.get_env(:crucible_feedback, :llm_judge)

    case judge do
      nil ->
        %{check: :llm_judge, score: 1.0, passed: true, details: %{skipped: true}}

      fun when is_function(fun, 1) ->
        normalize_result(fun.(event))

      module when is_atom(module) ->
        normalize_result(module.judge(event))
    end
  end

  defp normalize_result({:ok, score, details}) when is_number(score) do
    %{check: :llm_judge, score: score, passed: score >= 0.7, details: details}
  end

  defp normalize_result({:ok, score}) when is_number(score) do
    %{check: :llm_judge, score: score, passed: score >= 0.7, details: %{}}
  end

  defp normalize_result({:error, reason}) do
    %{check: :llm_judge, score: 0.0, passed: false, details: %{error: reason}}
  end

  defp normalize_result(other) do
    %{check: :llm_judge, score: 0.0, passed: false, details: %{error: other}}
  end
end
