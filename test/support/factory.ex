defmodule CrucibleFeedback.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: CrucibleFeedback.Repo

  def inference_event_factory do
    %CrucibleFeedback.Schemas.InferenceEvent{
      deployment_id: "deploy-123",
      model_version_id: "version-456",
      user_id_hash: sequence(:user_hash, &"user#{&1}"),
      prompt: "What is the capital of France?",
      response: "The capital of France is Paris.",
      latency_ms: :rand.uniform(500),
      token_count: :rand.uniform(100),
      quality_score: :rand.uniform() * 0.5 + 0.5,
      metadata: %{}
    }
  end

  def user_signal_factory do
    %CrucibleFeedback.Schemas.UserSignal{
      inference_event: build(:inference_event),
      signal_type: Enum.random([:thumbs_up, :thumbs_down, :copy]),
      metadata: %{}
    }
  end
end
