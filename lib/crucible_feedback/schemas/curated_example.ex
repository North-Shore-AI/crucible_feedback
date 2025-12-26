defmodule CrucibleFeedback.Schemas.CuratedExample do
  @moduledoc """
  Ecto schema for curated training examples.
  """

  use Ecto.Schema

  @type curation_source :: :high_quality | :hard_example | :diverse | :user_edit

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          inference_event_id: Ecto.UUID.t(),
          deployment_id: String.t(),
          curation_source: curation_source(),
          curation_score: float(),
          prompt: String.t(),
          response: String.t(),
          exported: boolean(),
          export_batch_id: String.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "curated_examples" do
    belongs_to(:inference_event, CrucibleFeedback.Schemas.InferenceEvent, type: :binary_id)

    field(:deployment_id, :string)

    field(:curation_source, Ecto.Enum,
      values: [:high_quality, :hard_example, :diverse, :user_edit]
    )

    field(:curation_score, :float)
    field(:prompt, :string)
    field(:response, :string)
    field(:exported, :boolean, default: false)
    field(:export_batch_id, :string)

    timestamps(type: :utc_datetime)
  end
end
