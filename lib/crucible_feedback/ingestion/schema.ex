defmodule CrucibleFeedback.Ingestion.Schema do
  @moduledoc """
  Validation schema for incoming inference events.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:deployment_id, :string)
    field(:model_version_id, :string)
    field(:user_id, :string)
    field(:user_id_hash, :string)
    field(:prompt, :string)
    field(:response, :string)
    field(:latency_ms, :integer)
    field(:token_count, :integer)
    field(:quality_score, :float)
    field(:metadata, :map, default: %{})
  end

  @required_fields [:deployment_id, :prompt, :response]
  @cast_fields [
    :deployment_id,
    :model_version_id,
    :user_id,
    :user_id_hash,
    :prompt,
    :response,
    :latency_ms,
    :token_count,
    :quality_score,
    :metadata
  ]

  @doc """
  Validate a raw event map.
  """
  @spec validate(map()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}
  def validate(attrs) when is_map(attrs) do
    changeset =
      %__MODULE__{}
      |> cast(attrs, @cast_fields)
      |> validate_required(@required_fields)
      |> validate_number(:latency_ms, greater_than_or_equal_to: 0)
      |> validate_number(:token_count, greater_than_or_equal_to: 0)

    if changeset.valid? do
      {:ok, changeset |> apply_changes() |> Map.from_struct()}
    else
      {:error, changeset}
    end
  end
end
