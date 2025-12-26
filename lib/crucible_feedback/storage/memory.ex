defmodule CrucibleFeedback.Storage.Memory do
  @moduledoc """
  In-memory storage backend for tests and local development.
  """

  @behaviour CrucibleFeedback.Storage

  use Agent

  @type state :: %{
          events: %{String.t() => map()},
          signals: %{String.t() => map()},
          curated: %{String.t() => map()}
        }

  @doc """
  Start the in-memory storage agent.
  """
  @spec start_link(keyword()) :: Agent.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.start_link(fn -> %{events: %{}, signals: %{}, curated: %{}} end, name: name)
  end

  @doc """
  Reset the in-memory state (testing utility).
  """
  @spec reset() :: :ok
  def reset do
    Agent.update(__MODULE__, fn _ -> %{events: %{}, signals: %{}, curated: %{}} end)
  end

  @doc false
  @impl true
  def insert_batch(events) do
    Agent.update(__MODULE__, fn state ->
      Enum.reduce(events, state, fn event, acc ->
        normalized = normalize_event(event)
        %{acc | events: Map.put(acc.events, normalized.id, normalized)}
      end)
    end)

    :ok
  end

  @doc false
  @impl true
  def insert_signal(signal) do
    normalized = normalize_signal(signal)

    Agent.update(__MODULE__, fn state ->
      %{state | signals: Map.put(state.signals, normalized.id, normalized)}
    end)

    {:ok, normalized}
  end

  @doc false
  @impl true
  def list_events(deployment_id, opts) do
    include_signals = Keyword.get(opts, :include_signals, false)
    limit = Keyword.get(opts, :limit)
    order = Keyword.get(opts, :order, :desc)

    events =
      Agent.get(__MODULE__, fn state ->
        state.events
        |> Map.values()
        |> Enum.filter(&(&1.deployment_id == deployment_id))
      end)
      |> maybe_attach_signals(include_signals)
      |> sort_by_inserted_at(order)
      |> maybe_take(limit)

    events
  end

  @doc false
  @impl true
  def list_events_with_edits(deployment_id, opts) do
    list_events(deployment_id, Keyword.put(opts, :include_signals, true))
    |> Enum.filter(fn event ->
      Enum.any?(Map.get(event, :signals, []), &(&1.signal_type == :edit))
    end)
  end

  @doc false
  @impl true
  def update_event(event_id, attrs) do
    Agent.update(__MODULE__, fn state ->
      case Map.fetch(state.events, event_id) do
        {:ok, event} ->
          updated = Map.merge(event, attrs)
          %{state | events: Map.put(state.events, event_id, updated)}

        :error ->
          state
      end
    end)

    :ok
  end

  @doc false
  @impl true
  def insert_curated_examples(examples) do
    Agent.update(__MODULE__, fn state ->
      Enum.reduce(examples, state, fn example, acc ->
        normalized = normalize_curated(example)
        %{acc | curated: Map.put(acc.curated, normalized.id, normalized)}
      end)
    end)

    :ok
  end

  @doc false
  @impl true
  def list_curated_examples(deployment_id, opts) do
    exported_filter = Keyword.get(opts, :exported)
    limit = Keyword.get(opts, :limit)

    Agent.get(__MODULE__, fn state ->
      state.curated
      |> Map.values()
      |> Enum.filter(&(&1.deployment_id == deployment_id))
      |> filter_by_exported(exported_filter)
    end)
    |> maybe_take(limit)
  end

  @doc false
  @impl true
  def mark_curated_exported(ids, batch_id) do
    now = DateTime.utc_now()

    Agent.update(__MODULE__, fn state ->
      %{state | curated: mark_exported(state.curated, ids, batch_id, now)}
    end)

    :ok
  end

  @doc false
  @impl true
  def count_curated_examples(deployment_id, opts) do
    list_curated_examples(deployment_id, opts) |> length()
  end

  @doc false
  @impl true
  def count_events(deployment_id, opts) do
    list_events(deployment_id, opts) |> length()
  end

  @doc false
  @impl true
  def list_signals_for_event(event_id) do
    Agent.get(__MODULE__, fn state ->
      state.signals
      |> Map.values()
      |> Enum.filter(&(&1.inference_event_id == event_id))
    end)
  end

  @doc false
  @impl true
  def list_signals(deployment_id, _opts) do
    events = list_events(deployment_id, include_signals: true)
    Enum.flat_map(events, &Map.get(&1, :signals, []))
  end

  defp normalize_event(event) do
    event
    |> Map.put_new(:id, Ecto.UUID.generate())
    |> Map.put_new(:inserted_at, DateTime.utc_now())
  end

  defp normalize_signal(signal) do
    signal
    |> Map.put_new(:id, Ecto.UUID.generate())
    |> Map.put_new(:inserted_at, DateTime.utc_now())
  end

  defp normalize_curated(example) do
    now = DateTime.utc_now()

    example
    |> Map.put_new(:id, Ecto.UUID.generate())
    |> Map.put_new(:inserted_at, now)
    |> Map.put_new(:updated_at, now)
    |> Map.put_new(:exported, false)
  end

  defp maybe_attach_signals(events, false), do: events

  defp maybe_attach_signals(events, true) do
    Enum.map(events, fn event ->
      signals = list_signals_for_event(event.id)
      Map.put(event, :signals, signals)
    end)
  end

  defp sort_by_inserted_at(events, :asc) do
    Enum.sort_by(events, &DateTime.to_unix(&1.inserted_at))
  end

  defp sort_by_inserted_at(events, _order) do
    Enum.sort_by(events, &DateTime.to_unix(&1.inserted_at), :desc)
  end

  defp maybe_take(events, nil), do: events
  defp maybe_take(events, limit), do: Enum.take(events, limit)

  defp filter_by_exported(events, true), do: Enum.filter(events, & &1.exported)
  defp filter_by_exported(events, false), do: Enum.filter(events, &(not &1.exported))
  defp filter_by_exported(events, _), do: events

  defp mark_exported(curated, ids, batch_id, now) do
    Enum.reduce(ids, curated, fn id, acc ->
      case Map.fetch(acc, id) do
        {:ok, example} ->
          updated = %{example | exported: true, export_batch_id: batch_id, updated_at: now}
          Map.put(acc, id, updated)

        :error ->
          acc
      end
    end)
  end
end
