defmodule CrucibleFeedback.IngestionTest do
  use ExUnit.Case, async: false

  import Mox

  alias CrucibleFeedback.Ingestion
  alias CrucibleFeedback.Storage.Mock, as: StorageMock

  setup :set_mox_from_context
  setup :verify_on_exit!

  defp start_ingestion(opts) do
    pid = start_supervised!({Ingestion, opts})
    Mox.allow(StorageMock, self(), pid)
    pid
  end

  test "flushes when max batch size is reached" do
    test_pid = self()

    StorageMock
    |> expect(:insert_batch, fn events ->
      send(test_pid, {:flushed, events})
      :ok
    end)

    start_ingestion(storage: StorageMock, flush_interval: 1_000, max_batch_size: 2)

    Ingestion.log_inference(%{deployment_id: "d1", prompt: "email a@b.com", response: "ok"})
    Ingestion.log_inference(%{deployment_id: "d1", prompt: "ok", response: "ssn 123-45-6789"})

    assert_receive {:flushed, events}, 500
    assert length(events) == 2
    assert Enum.any?(events, &String.contains?(&1.prompt, "[EMAIL]"))
    assert Enum.any?(events, &String.contains?(&1.response, "[SSN]"))
  end

  test "flushes on interval even if batch is not full" do
    test_pid = self()

    StorageMock
    |> expect(:insert_batch, fn events ->
      send(test_pid, {:flushed, events})
      :ok
    end)

    start_ingestion(storage: StorageMock, flush_interval: 20, max_batch_size: 10)

    Ingestion.log_inference(%{deployment_id: "d1", prompt: "ok", response: "ok"})

    assert_receive {:flushed, events}, 200
    assert length(events) == 1
  end
end
