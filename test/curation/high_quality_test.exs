defmodule CrucibleFeedback.Curation.HighQualityTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Curation.HighQuality

  defp signal(type), do: %{signal_type: type}

  test "selects high quality events with positive signals" do
    events = [
      %{
        id: "1",
        deployment_id: "d1",
        prompt: "p1",
        response: "r1",
        quality_score: 0.9,
        signals: [signal(:thumbs_up)]
      },
      %{
        id: "2",
        deployment_id: "d1",
        prompt: "p2",
        response: "r2",
        quality_score: 0.9,
        signals: []
      },
      %{
        id: "3",
        deployment_id: "d1",
        prompt: "p3",
        response: "r3",
        quality_score: 0.6,
        signals: [signal(:thumbs_up)]
      }
    ]

    curated = HighQuality.select(events, limit: 10, min_quality_score: 0.8)

    assert length(curated) == 1
    assert hd(curated).curation_source == :high_quality
    assert hd(curated).inference_event_id == "1"
  end
end
