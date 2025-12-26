defmodule CrucibleFeedback.Repo.Migrations.CreateInferenceEvents do
  use Ecto.Migration

  def change do
    create table(:inference_events, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:deployment_id, :string, null: false)
      add(:model_version_id, :string)
      add(:user_id_hash, :string)
      add(:prompt, :text, null: false)
      add(:response, :text, null: false)
      add(:latency_ms, :integer)
      add(:token_count, :integer)
      add(:quality_score, :float)
      add(:metadata, :map, default: %{})

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create(index(:inference_events, [:deployment_id]))
    create(index(:inference_events, [:model_version_id]))
    create(index(:inference_events, [:inserted_at]))
  end
end
