defmodule CrucibleFeedback.Quality.FormatCheck do
  @moduledoc """
  Check response format (JSON validity, markdown structure).
  """

  @doc """
  Score response format (JSON/markdown/plain).
  """
  @spec check(map()) :: map()
  def check(event) do
    response = Map.get(event, :response, "")

    {score, details} =
      cond do
        json_valid?(response) -> {1.0, %{format: :json, valid: true}}
        markdown_wellformed?(response) -> {0.9, %{format: :markdown, valid: true}}
        true -> {0.7, %{format: :plain, valid: true}}
      end

    %{check: :format, score: score, passed: score >= 0.7, details: details}
  end

  defp json_valid?(text) do
    case Jason.decode(text) do
      {:ok, _} -> true
      _ -> false
    end
  end

  defp markdown_wellformed?(text) do
    String.contains?(text, "```") and balanced_code_blocks?(text)
  end

  defp balanced_code_blocks?(text) do
    count = length(Regex.scan(~r/```/, text))
    rem(count, 2) == 0
  end
end
