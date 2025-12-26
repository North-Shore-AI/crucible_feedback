defmodule CrucibleFeedback.Repo.Migrations.CreateCuratedExamples do
  use Ecto.Migration

  def change do
    create table(:curated_examples, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(
        :inference_event_id,
        references(:inference_events, type: :binary_id, on_delete: :delete_all),
        null: false
      )

      add(:deployment_id, :string, null: false)
      add(:curation_source, :string, null: false)
      add(:curation_score, :float)
      add(:prompt, :text)
      add(:response, :text)
      add(:exported, :boolean, default: false)
      add(:export_batch_id, :string)

      timestamps(type: :utc_datetime)
    end

    create(index(:curated_examples, [:deployment_id]))
    create(index(:curated_examples, [:curation_source]))
    create(index(:curated_examples, [:exported]))
  end
end
