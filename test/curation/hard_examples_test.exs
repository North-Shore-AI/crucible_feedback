defmodule CrucibleFeedback.Curation.HardExamplesTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Curation.HardExamples

  defp signal(type), do: %{signal_type: type}

  test "selects low quality or negative signal events" do
    events = [
      %{
        id: "1",
        deployment_id: "d1",
        prompt: "p1",
        response: "r1",
        quality_score: 0.3,
        signals: []
      },
      %{
        id: "2",
        deployment_id: "d1",
        prompt: "p2",
        response: "r2",
        quality_score: 0.9,
        signals: [signal(:thumbs_down)]
      },
      %{
        id: "3",
        deployment_id: "d1",
        prompt: "p3",
        response: "r3",
        quality_score: 0.9,
        signals: []
      }
    ]

    curated = HardExamples.select(events, limit: 10, max_quality_score: 0.5)

    assert Enum.map(curated, & &1.inference_event_id) |> Enum.sort() == ["1", "2"]
    assert Enum.all?(curated, &(&1.curation_source == :hard_example))
  end
end
