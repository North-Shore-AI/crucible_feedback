defmodule CrucibleFeedback.Curation.Diverse do
  @moduledoc """
  Select diverse examples using embedding space distance.
  """

  @doc """
  Select diverse events using embedding distances when available.
  """
  @spec select([map()], keyword()) :: [map()]
  def select(events, opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)

    embedding_client =
      Keyword.get(
        opts,
        :embedding_client,
        Application.get_env(:crucible_feedback, :embedding_client)
      )

    case embed_events(events, embedding_client) do
      {:ok, embedded} ->
        embedded
        |> sort_by_distance_from_centroid()
        |> Enum.take(limit)
        |> Enum.map(fn {event, _distance} ->
          to_curated_example(event, :diverse, 1.0)
        end)

      {:error, _reason} ->
        events
        |> Enum.sort_by(&String.length(Map.get(&1, :prompt, "")), :desc)
        |> Enum.take(limit)
        |> Enum.map(&to_curated_example(&1, :diverse, 1.0))
    end
  end

  defp embed_events([], _client), do: {:error, :empty_window}
  defp embed_events(_events, nil), do: {:error, :embedding_client_not_configured}

  defp embed_events(events, client) do
    prompts = Enum.map(events, &Map.get(&1, :prompt, ""))

    with {:ok, embeddings} <- client.embed_batch(prompts) do
      {:ok, Enum.zip(events, embeddings)}
    end
  end

  defp sort_by_distance_from_centroid(embedded) do
    vectors = Enum.map(embedded, fn {_event, vector} -> vector end)
    {:ok, centroid} = centroid(vectors)

    embedded
    |> Enum.map(fn {event, vector} -> {event, euclidean_distance(vector, centroid)} end)
    |> Enum.sort_by(fn {_event, distance} -> distance end, :desc)
  end

  defp centroid([]), do: {:error, :empty_embeddings}

  defp centroid(vectors) do
    dim = vectors |> List.first() |> length()
    sums = Enum.reduce(vectors, List.duplicate(0.0, dim), &sum_vectors/2)
    count = length(vectors)

    {:ok, Enum.map(sums, &(&1 / count))}
  end

  defp sum_vectors(vector, acc) do
    Enum.zip(vector, acc)
    |> Enum.map(fn {v, a} -> v + a end)
  end

  defp euclidean_distance(a, b) do
    a
    |> Enum.zip(b)
    |> Enum.reduce(0.0, fn {x, y}, acc -> acc + :math.pow(x - y, 2) end)
    |> :math.sqrt()
  end

  defp to_curated_example(event, source, score) do
    %{
      inference_event_id: event.id,
      deployment_id: event.deployment_id,
      curation_source: source,
      curation_score: score,
      prompt: event.prompt,
      response: event.response
    }
  end
end
