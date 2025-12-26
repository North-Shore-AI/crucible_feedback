defmodule CrucibleFeedback.Drift.Embedding do
  @moduledoc """
  Embedding-based drift detection.
  """

  @doc """
  Compute embedding centroid distance between two windows.
  """
  @spec detect([map()], [map()], keyword()) :: map()
  def detect(window_a, window_b, opts \\ []) do
    embedding_client =
      Keyword.get(
        opts,
        :embedding_client,
        Application.get_env(:crucible_feedback, :embedding_client)
      )

    drift_threshold = Keyword.get(opts, :drift_threshold, 0.5)

    prompts_a = Enum.map(window_a, &Map.get(&1, :prompt, ""))
    prompts_b = Enum.map(window_b, &Map.get(&1, :prompt, ""))

    with {:ok, embeddings_a} <- embed_batch(embedding_client, prompts_a),
         {:ok, embeddings_b} <- embed_batch(embedding_client, prompts_b),
         {:ok, centroid_a} <- centroid(embeddings_a),
         {:ok, centroid_b} <- centroid(embeddings_b) do
      distance = euclidean_distance(centroid_a, centroid_b)
      drifted = distance > drift_threshold

      %{type: :embedding, score: distance, drifted: drifted, details: %{distance: distance}}
    else
      {:error, reason} ->
        %{
          type: :embedding,
          score: 0.0,
          drifted: false,
          details: %{error: reason}
        }
    end
  end

  defp embed_batch(client, prompts) do
    cond do
      prompts == [] ->
        {:error, :empty_window}

      function_exported?(client, :embed_batch, 1) ->
        client.embed_batch(prompts)

      function_exported?(client, :embed, 1) ->
        embed_individual(client, prompts)

      true ->
        {:error, :embedding_client_not_configured}
    end
  end

  defp embed_individual(client, prompts) do
    prompts
    |> Enum.reduce_while({:ok, []}, fn prompt, {:ok, acc} ->
      case client.embed(prompt) do
        {:ok, vector} -> {:cont, {:ok, [vector | acc]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> normalize_embeddings()
  end

  defp normalize_embeddings({:ok, vectors}), do: {:ok, Enum.reverse(vectors)}
  defp normalize_embeddings(other), do: other

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
end
