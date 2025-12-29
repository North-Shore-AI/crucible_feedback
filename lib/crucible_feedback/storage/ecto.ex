defmodule CrucibleFeedback.Storage.Ecto do
  @moduledoc """
  Ecto/Postgres storage backend.
  """

  @behaviour CrucibleFeedback.Storage

  import Ecto.Query

  alias CrucibleFeedback.Schemas.{CuratedExample, InferenceEvent, UserSignal}

  defp repo, do: CrucibleFeedback.repo()

  @doc false
  @impl true
  def insert_batch(events) do
    now = DateTime.utc_now()

    entries =
      Enum.map(events, fn event ->
        event
        |> Map.put_new(:id, Ecto.UUID.generate())
        |> Map.put_new(:inserted_at, now)
        |> Map.take([
          :id,
          :deployment_id,
          :model_version_id,
          :user_id_hash,
          :prompt,
          :response,
          :latency_ms,
          :token_count,
          :quality_score,
          :metadata,
          :inserted_at
        ])
      end)

    repo().insert_all(InferenceEvent, entries)
    :ok
  end

  @doc false
  @impl true
  def insert_signal(signal) do
    struct = struct(UserSignal, signal)

    case repo().insert(struct) do
      {:ok, record} -> {:ok, record}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc false
  @impl true
  def list_events(deployment_id, opts) do
    include_signals = Keyword.get(opts, :include_signals, false)
    limit = Keyword.get(opts, :limit)
    order = Keyword.get(opts, :order, :desc)

    query =
      from(event in InferenceEvent,
        where: event.deployment_id == ^deployment_id,
        order_by: [{^order, event.inserted_at}]
      )

    query = if limit, do: from(event in query, limit: ^limit), else: query
    query = if include_signals, do: preload(query, [:signals]), else: query

    repo().all(query)
  end

  @doc false
  @impl true
  def list_events_with_edits(deployment_id, opts) do
    list_events(deployment_id, Keyword.put(opts, :include_signals, true))
    |> Enum.filter(fn event ->
      Enum.any?(event.signals, &(&1.signal_type == :edit))
    end)
  end

  @doc false
  @impl true
  def update_event(event_id, attrs) do
    case repo().get(InferenceEvent, event_id) do
      nil ->
        {:error, :not_found}

      event ->
        event
        |> InferenceEvent.changeset(attrs)
        |> repo().update()
        |> case do
          {:ok, _} -> :ok
          {:error, reason} -> {:error, reason}
        end
    end
  end

  @doc false
  @impl true
  def insert_curated_examples(examples) do
    now = DateTime.utc_now()

    entries =
      Enum.map(examples, fn example ->
        example
        |> Map.put_new(:id, Ecto.UUID.generate())
        |> Map.put_new(:inserted_at, now)
        |> Map.put_new(:updated_at, now)
        |> Map.take([
          :id,
          :inference_event_id,
          :deployment_id,
          :curation_source,
          :curation_score,
          :prompt,
          :response,
          :exported,
          :export_batch_id,
          :inserted_at,
          :updated_at
        ])
      end)

    repo().insert_all(CuratedExample, entries)
    :ok
  end

  @doc false
  @impl true
  def list_curated_examples(deployment_id, opts) do
    exported_filter = Keyword.get(opts, :exported)
    limit = Keyword.get(opts, :limit)

    query = from(example in CuratedExample, where: example.deployment_id == ^deployment_id)

    query =
      case exported_filter do
        true -> from(example in query, where: example.exported == true)
        false -> from(example in query, where: example.exported == false)
        _ -> query
      end

    query = if limit, do: from(example in query, limit: ^limit), else: query

    repo().all(query)
  end

  @doc false
  @impl true
  def mark_curated_exported(ids, batch_id) do
    from(example in CuratedExample, where: example.id in ^ids)
    |> repo().update_all(
      set: [exported: true, export_batch_id: batch_id, updated_at: DateTime.utc_now()]
    )

    :ok
  end

  @doc false
  @impl true
  def count_curated_examples(deployment_id, opts) do
    exported_filter = Keyword.get(opts, :exported)

    query = from(example in CuratedExample, where: example.deployment_id == ^deployment_id)

    query =
      case exported_filter do
        true -> from(example in query, where: example.exported == true)
        false -> from(example in query, where: example.exported == false)
        _ -> query
      end

    repo().aggregate(query, :count)
  end

  @doc false
  @impl true
  def count_events(deployment_id, _opts) do
    from(event in InferenceEvent, where: event.deployment_id == ^deployment_id)
    |> repo().aggregate(:count)
  end

  @doc false
  @impl true
  def list_signals_for_event(event_id) do
    from(signal in UserSignal, where: signal.inference_event_id == ^event_id)
    |> repo().all()
  end

  @doc false
  @impl true
  def list_signals(deployment_id, _opts) do
    from(signal in UserSignal,
      join: event in InferenceEvent,
      on: signal.inference_event_id == event.id,
      where: event.deployment_id == ^deployment_id
    )
    |> repo().all()
  end
end
