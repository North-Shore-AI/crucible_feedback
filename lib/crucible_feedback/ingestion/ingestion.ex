defmodule CrucibleFeedback.Ingestion do
  @moduledoc """
  Batch-buffered event ingestion with PII sanitization.
  """

  use GenServer

  alias CrucibleFeedback.Ingestion.{Event, Sanitizer, Schema}

  @default_flush_interval :timer.seconds(5)
  @default_max_batch_size 1_000

  defstruct [:storage, :buffer, :timer_ref, :flush_interval, :max_batch_size]

  @type state :: %__MODULE__{
          storage: module(),
          buffer: [map()],
          timer_ref: reference() | nil,
          flush_interval: non_neg_integer(),
          max_batch_size: pos_integer()
        }

  @doc """
  Start the ingestion GenServer.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Log an inference event asynchronously.
  """
  @spec log_inference(map()) :: :ok
  def log_inference(event) when is_map(event) do
    GenServer.cast(__MODULE__, {:log, event})
  end

  @impl true
  @doc false
  def init(opts) do
    config = Application.get_env(:crucible_feedback, :ingestion, [])

    storage = Keyword.get(opts, :storage) || Application.get_env(:crucible_feedback, :storage)

    flush_interval =
      Keyword.get(opts, :flush_interval, config[:flush_interval] || @default_flush_interval)

    max_batch_size =
      Keyword.get(opts, :max_batch_size, config[:max_batch_size] || @default_max_batch_size)

    timer_ref = schedule_flush(flush_interval)

    {:ok,
     %__MODULE__{
       storage: storage,
       buffer: [],
       timer_ref: timer_ref,
       flush_interval: flush_interval,
       max_batch_size: max_batch_size
     }}
  end

  @impl true
  @doc false
  def handle_cast({:log, event}, state) do
    case Schema.validate(event) do
      {:ok, valid} ->
        sanitized = valid |> Sanitizer.sanitize() |> Event.from_map() |> Event.to_map()
        new_buffer = [sanitized | state.buffer]

        if length(new_buffer) >= state.max_batch_size do
          flush_buffer(new_buffer, state.storage)
          {:noreply, %{state | buffer: []}}
        else
          {:noreply, %{state | buffer: new_buffer}}
        end

      {:error, changeset} ->
        :telemetry.execute(
          [:crucible_feedback, :ingestion, :invalid],
          %{count: 1},
          %{errors: changeset.errors}
        )

        {:noreply, state}
    end
  end

  @impl true
  @doc false
  def handle_info(:flush, state) do
    if state.buffer != [] do
      flush_buffer(state.buffer, state.storage)
    end

    timer_ref = schedule_flush(state.flush_interval)
    {:noreply, %{state | buffer: [], timer_ref: timer_ref}}
  end

  defp schedule_flush(interval), do: Process.send_after(self(), :flush, interval)

  defp flush_buffer(events, storage) do
    :telemetry.execute(
      [:crucible_feedback, :ingestion, :flush],
      %{count: length(events)},
      %{}
    )

    storage.insert_batch(Enum.reverse(events))
  end
end
