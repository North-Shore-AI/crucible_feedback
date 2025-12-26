defmodule CrucibleFeedback.Storage.Clickhouse do
  @moduledoc """
  ClickHouse storage backend placeholder.

  This module can be extended to write high-volume telemetry to ClickHouse.
  """

  @behaviour CrucibleFeedback.Storage

  @doc false
  @impl true
  def insert_batch(_events), do: {:error, :not_supported}

  @doc false
  @impl true
  def insert_signal(_signal), do: {:error, :not_supported}

  @doc false
  @impl true
  def list_events(_deployment_id, _opts), do: []

  @doc false
  @impl true
  def list_events_with_edits(_deployment_id, _opts), do: []

  @doc false
  @impl true
  def update_event(_event_id, _attrs), do: {:error, :not_supported}

  @doc false
  @impl true
  def insert_curated_examples(_examples), do: {:error, :not_supported}

  @doc false
  @impl true
  def list_curated_examples(_deployment_id, _opts), do: []

  @doc false
  @impl true
  def mark_curated_exported(_ids, _batch_id), do: {:error, :not_supported}

  @doc false
  @impl true
  def count_curated_examples(_deployment_id, _opts), do: 0

  @doc false
  @impl true
  def count_events(_deployment_id, _opts), do: 0

  @doc false
  @impl true
  def list_signals_for_event(_event_id), do: []

  @doc false
  @impl true
  def list_signals(_deployment_id, _opts), do: []
end
