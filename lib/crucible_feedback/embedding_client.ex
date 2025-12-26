defmodule CrucibleFeedback.EmbeddingClient do
  @moduledoc """
  Behaviour for embedding providers used in drift detection and curation.
  """

  @callback embed(String.t()) :: {:ok, [number()]} | {:error, term()}
  @callback embed_batch([String.t()]) :: {:ok, [[number()]]} | {:error, term()}
end

defmodule CrucibleFeedback.EmbeddingClient.Noop do
  @moduledoc """
  Default embedding client that returns errors when no provider is configured.
  """

  @behaviour CrucibleFeedback.EmbeddingClient

  @doc false
  @impl true
  def embed(_text), do: {:error, :embedding_client_not_configured}

  @doc false
  @impl true
  def embed_batch(_texts), do: {:error, :embedding_client_not_configured}
end
