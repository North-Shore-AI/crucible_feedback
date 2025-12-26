defmodule CrucibleFeedback.Quality.LengthCheck do
  @moduledoc """
  Detect responses that are too short or too long.
  """

  @doc """
  Score response length against configured bounds.
  """
  @spec check(map(), keyword()) :: map()
  def check(event, opts \\ []) do
    response = Map.get(event, :response, "")
    length = String.length(response)

    {min_length, max_length} = bounds(opts)

    cond do
      length < min_length ->
        %{
          check: :length,
          score: 0.4,
          passed: false,
          details: %{
            length: length,
            min: min_length,
            max: max_length,
            too_short: true,
            too_long: false
          }
        }

      length > max_length ->
        %{
          check: :length,
          score: 0.4,
          passed: false,
          details: %{
            length: length,
            min: min_length,
            max: max_length,
            too_short: false,
            too_long: true
          }
        }

      true ->
        %{
          check: :length,
          score: 1.0,
          passed: true,
          details: %{
            length: length,
            min: min_length,
            max: max_length,
            too_short: false,
            too_long: false
          }
        }
    end
  end

  defp bounds(opts) do
    config = Application.get_env(:crucible_feedback, :quality, [])

    min_length = Keyword.get(opts, :min_length, config[:min_length] || 20)
    max_length = Keyword.get(opts, :max_length, config[:max_length] || 4_000)

    {min_length, max_length}
  end
end
