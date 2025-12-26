defmodule CrucibleFeedback.Schemas.UserSignal do
  @moduledoc """
  Ecto schema for user feedback signals.
  """

  use Ecto.Schema

  @type signal_type :: :thumbs_up | :thumbs_down | :regenerate | :edit | :copy | :share | :report

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          inference_event_id: Ecto.UUID.t(),
          signal_type: signal_type(),
          edited_response: String.t() | nil,
          metadata: map(),
          inserted_at: DateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "user_signals" do
    belongs_to(:inference_event, CrucibleFeedback.Schemas.InferenceEvent, type: :binary_id)

    field(:signal_type, Ecto.Enum,
      values: [:thumbs_up, :thumbs_down, :regenerate, :edit, :copy, :share, :report]
    )

    field(:edited_response, :string)
    field(:metadata, :map, default: %{})

    timestamps(type: :utc_datetime, updated_at: false)
  end
end
