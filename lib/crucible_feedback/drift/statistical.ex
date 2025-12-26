defmodule CrucibleFeedback.Drift.Statistical do
  @moduledoc """
  Statistical drift detection (KS test, PSI).
  """

  @doc """
  Compute KS and PSI drift statistics between two windows.
  """
  @spec detect([map()], [map()], keyword()) :: map()
  def detect(window_a, window_b, opts \\ []) do
    lengths_a = Enum.map(window_a, &String.length(Map.get(&1, :prompt, "")))
    lengths_b = Enum.map(window_b, &String.length(Map.get(&1, :prompt, "")))

    ks_stat = kolmogorov_smirnov(lengths_a, lengths_b)
    psi = population_stability_index(lengths_a, lengths_b)

    ks_threshold = Keyword.get(opts, :ks_threshold, 0.1)
    psi_threshold = Keyword.get(opts, :psi_threshold, 0.2)

    drifted = ks_stat > ks_threshold or psi > psi_threshold
    score = max(ks_stat, psi)

    %{
      type: :statistical,
      score: score,
      drifted: drifted,
      details: %{ks_statistic: ks_stat, psi: psi}
    }
  end

  defp kolmogorov_smirnov(a, b) do
    values = Enum.sort(Enum.uniq(a ++ b))

    Enum.reduce(values, 0.0, fn value, acc ->
      cdf_a = empirical_cdf(a, value)
      cdf_b = empirical_cdf(b, value)
      max(acc, abs(cdf_a - cdf_b))
    end)
  end

  defp empirical_cdf(list, value) do
    count = Enum.count(list, &(&1 <= value))
    count / max(length(list), 1)
  end

  defp population_stability_index([], _), do: 0.0
  defp population_stability_index(_, []), do: 0.0

  defp population_stability_index(a, b) do
    bins = 10
    min_value = Enum.min(a ++ b)
    max_value = Enum.max(a ++ b)

    if min_value == max_value do
      0.0
    else
      width = (max_value - min_value) / bins
      edges = Enum.map(0..bins, &(min_value + &1 * width))

      expected = bucket_probs(a, edges)
      actual = bucket_probs(b, edges)

      expected_tensor = Nx.tensor(expected)
      actual_tensor = Nx.tensor(actual)
      epsilon = 1.0e-6

      expected_tensor = Nx.max(expected_tensor, epsilon)
      actual_tensor = Nx.max(actual_tensor, epsilon)

      psi =
        actual_tensor
        |> Nx.subtract(expected_tensor)
        |> Nx.multiply(Nx.log(Nx.divide(actual_tensor, expected_tensor)))
        |> Nx.sum()
        |> Nx.to_number()

      psi
    end
  end

  defp bucket_probs(values, edges) do
    total = max(length(values), 1)

    edges
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [min_edge, max_edge] ->
      count = Enum.count(values, &(&1 >= min_edge and &1 < max_edge))
      count / total
    end)
  end
end
