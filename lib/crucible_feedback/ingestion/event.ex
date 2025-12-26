defmodule CrucibleFeedback.Ingestion.Event do
  @moduledoc """
  Struct representing an inference event after validation/sanitization.
  """

  @type t :: %__MODULE__{
          id: String.t(),
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

  defstruct [
    :id,
    :deployment_id,
    :model_version_id,
    :user_id_hash,
    :prompt,
    :response,
    :latency_ms,
    :token_count,
    :quality_score,
    inserted_at: nil,
    metadata: %{}
  ]

  @doc """
  Build an Event struct from a map, applying defaults for id and timestamps.
  """
  @spec from_map(map()) :: t()
  def from_map(attrs) do
    attrs
    |> Map.put_new(:id, Ecto.UUID.generate())
    |> Map.put_new(:inserted_at, DateTime.utc_now())
    |> then(&struct!(__MODULE__, &1))
  end

  @doc """
  Convert an Event struct or map into a plain map for storage.
  """
  @spec to_map(t() | map()) :: map()
  def to_map(%__MODULE__{} = event), do: Map.from_struct(event)
  def to_map(attrs) when is_map(attrs), do: attrs
end
