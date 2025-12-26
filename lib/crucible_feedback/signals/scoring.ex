defmodule CrucibleFeedback.Signals.Scoring do
  @moduledoc """
  Scoring utilities for user signals.
  """

  alias CrucibleFeedback.Signals.Signal

  @doc """
  Return a numeric weight for a signal type.
  """
  @spec score(Signal.signal_type()) :: integer()
  def score(signal_type) do
    case signal_type do
      :thumbs_up -> 3
      :copy -> 2
      :share -> 2
      :edit -> 5
      :regenerate -> -1
      :thumbs_down -> -2
      :report -> -3
    end
  end
end
