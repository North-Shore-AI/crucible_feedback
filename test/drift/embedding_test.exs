defmodule CrucibleFeedback.Drift.EmbeddingTest do
  use ExUnit.Case, async: true

  import Mox

  alias CrucibleFeedback.Drift.Embedding
  alias CrucibleFeedback.EmbeddingClient.Mock, as: EmbeddingMock

  setup :set_mox_from_context
  setup :verify_on_exit!

  test "detects embedding drift via centroid distance" do
    window_a = [%{prompt: "A1"}, %{prompt: "A2"}, %{prompt: "A3"}]
    window_b = [%{prompt: "B1"}, %{prompt: "B2"}, %{prompt: "B3"}]

    EmbeddingMock
    |> expect(:embed_batch, 2, fn prompts ->
      if Enum.any?(prompts, &String.starts_with?(&1, "A")) do
        {:ok, [[0.0, 0.0], [0.0, 0.0], [0.0, 0.0]]}
      else
        {:ok, [[10.0, 10.0], [10.0, 10.0], [10.0, 10.0]]}
      end
    end)

    result =
      Embedding.detect(window_a, window_b, embedding_client: EmbeddingMock, drift_threshold: 5.0)

    assert result.type == :embedding
    assert result.drifted
    assert result.score >= 5.0
  end
end
