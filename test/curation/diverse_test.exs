defmodule CrucibleFeedback.Curation.DiverseTest do
  use ExUnit.Case, async: true

  import Mox

  alias CrucibleFeedback.Curation.Diverse
  alias CrucibleFeedback.EmbeddingClient.Mock, as: EmbeddingMock

  setup :set_mox_from_context
  setup :verify_on_exit!

  test "selects diverse examples using embeddings" do
    events = [
      %{id: "a", deployment_id: "d1", prompt: "A", response: "r1"},
      %{id: "b", deployment_id: "d1", prompt: "B", response: "r2"},
      %{id: "c", deployment_id: "d1", prompt: "C", response: "r3"}
    ]

    EmbeddingMock
    |> expect(:embed_batch, fn prompts ->
      vectors =
        Enum.map(prompts, fn
          "A" -> [0.0, 0.0]
          "B" -> [5.0, 5.0]
          "C" -> [10.0, 10.0]
        end)

      {:ok, vectors}
    end)

    curated = Diverse.select(events, limit: 2, embedding_client: EmbeddingMock)

    assert Enum.map(curated, & &1.inference_event_id) |> Enum.sort() == ["a", "c"]
    assert Enum.all?(curated, &(&1.curation_source == :diverse))
  end
end
