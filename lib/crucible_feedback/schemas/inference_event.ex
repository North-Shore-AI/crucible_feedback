defmodule CrucibleFeedback.Schemas.InferenceEvent do
  @moduledoc """
  Ecto schema for stored inference events.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          deployment_id: String.t(),
          model_version_id: String.t() | nil,
          user_id_hash: String.t() | nil,
          prompt: String.t(),
          response: String.t(),
          latency_ms: integer() | nil,
          token_count: integer() | nil,
          quality_score: float() | nil,
          metadata: map(),
          inserted_at: DateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "inference_events" do
    field(:deployment_id, :string)
    field(:model_version_id, :string)
    field(:user_id_hash, :string)
    field(:prompt, :string)
    field(:response, :string)
    field(:latency_ms, :integer)
    field(:token_count, :integer)
    field(:quality_score, :float)
    field(:metadata, :map, default: %{})

    has_many(:signals, CrucibleFeedback.Schemas.UserSignal)

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc """
  Build a changeset for inference events.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :deployment_id,
      :model_version_id,
      :user_id_hash,
      :prompt,
      :response,
      :latency_ms,
      :token_count,
      :quality_score,
      :metadata
    ])
    |> validate_required([:deployment_id, :prompt, :response])
  end
end
