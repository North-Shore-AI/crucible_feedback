defmodule CrucibleFeedback.SignalsTest do
  use ExUnit.Case, async: true

  import Mox

  alias CrucibleFeedback.Signals
  alias CrucibleFeedback.Storage.Mock, as: StorageMock

  setup :set_mox_from_context
  setup :verify_on_exit!

  test "records a user signal via storage" do
    StorageMock
    |> expect(:insert_signal, fn signal ->
      send(self(), {:signal, signal})
      {:ok, signal}
    end)

    {:ok, _signal} =
      Signals.record_signal("event-1", :thumbs_up, %{source: "ui"}, storage: StorageMock)

    assert_receive {:signal, signal}
    assert signal.inference_event_id == "event-1"
    assert signal.signal_type == :thumbs_up
  end

  test "records a user edit signal" do
    StorageMock
    |> expect(:insert_signal, fn signal ->
      send(self(), {:signal, signal})
      {:ok, signal}
    end)

    {:ok, _signal} = Signals.record_user_edit("event-2", "edited", storage: StorageMock)

    assert_receive {:signal, signal}
    assert signal.signal_type == :edit
    assert signal.edited_response == "edited"
  end
end
