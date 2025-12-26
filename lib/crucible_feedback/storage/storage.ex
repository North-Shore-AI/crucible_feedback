defmodule CrucibleFeedback.Storage do
  @moduledoc """
  Storage behaviour for feedback ingestion, signals, curation, and export.
  """

  @type event :: map()
  @type signal :: map()
  @type curated_example :: map()

  @callback insert_batch([event()]) :: :ok | {:error, term()}
  @callback insert_signal(signal()) :: {:ok, signal()} | {:error, term()}
  @callback list_events(String.t(), keyword()) :: [event()]
  @callback list_events_with_edits(String.t(), keyword()) :: [event()]
  @callback update_event(String.t(), map()) :: :ok | {:error, term()}
  @callback insert_curated_examples([curated_example()]) :: :ok | {:error, term()}
  @callback list_curated_examples(String.t(), keyword()) :: [curated_example()]
  @callback mark_curated_exported([String.t()], String.t()) :: :ok | {:error, term()}
  @callback count_curated_examples(String.t(), keyword()) :: non_neg_integer()
  @callback count_events(String.t(), keyword()) :: non_neg_integer()
  @callback list_signals_for_event(String.t()) :: [signal()]
  @callback list_signals(String.t(), keyword()) :: [signal()]
end
