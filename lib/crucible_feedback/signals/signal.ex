defmodule CrucibleFeedback.Signals.Signal do
  @moduledoc """
  Signal struct representing user feedback.
  """

  @type signal_type :: :thumbs_up | :thumbs_down | :regenerate | :edit | :copy | :share | :report

  @type t :: %__MODULE__{
          id: String.t(),
          inference_event_id: String.t(),
          signal_type: signal_type(),
          edited_response: String.t() | nil,
          metadata: map(),
          inserted_at: DateTime.t()
        }

  defstruct [
    :id,
    :inference_event_id,
    :signal_type,
    :edited_response,
    inserted_at: nil,
    metadata: %{}
  ]

  @doc """
  Build a new signal struct.
  """
  @spec new(String.t(), signal_type(), map(), String.t() | nil) :: t()
  def new(inference_event_id, signal_type, metadata, edited_response \\ nil) do
    %__MODULE__{
      id: Ecto.UUID.generate(),
      inference_event_id: inference_event_id,
      signal_type: signal_type,
      edited_response: edited_response,
      metadata: metadata,
      inserted_at: DateTime.utc_now()
    }
  end
end
