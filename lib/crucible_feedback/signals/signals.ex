defmodule CrucibleFeedback.Signals do
  @moduledoc """
  APIs for recording user signals.
  """

  alias CrucibleFeedback.Signals.Signal

  @doc """
  Record a user signal for an inference event.
  """
  @spec record_signal(String.t(), Signal.signal_type(), map(), keyword()) ::
          {:ok, map()} | {:error, term()}
  def record_signal(inference_id, signal_type, metadata \\ %{}, opts \\ []) do
    storage = Keyword.get(opts, :storage, Application.get_env(:crucible_feedback, :storage))
    signal = Signal.new(inference_id, signal_type, metadata)
    storage.insert_signal(Map.from_struct(signal))
  end

  @doc """
  Record a user edit signal with the edited response.
  """
  @spec record_user_edit(String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def record_user_edit(inference_id, edited_response, opts \\ []) do
    storage = Keyword.get(opts, :storage, Application.get_env(:crucible_feedback, :storage))
    signal = Signal.new(inference_id, :edit, %{}, edited_response)
    storage.insert_signal(Map.from_struct(signal))
  end
end
