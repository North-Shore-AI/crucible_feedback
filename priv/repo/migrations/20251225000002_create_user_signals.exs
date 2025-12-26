defmodule CrucibleFeedback.Repo.Migrations.CreateUserSignals do
  use Ecto.Migration

  def change do
    create table(:user_signals, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(
        :inference_event_id,
        references(:inference_events, type: :binary_id, on_delete: :delete_all),
        null: false
      )

      add(:signal_type, :string, null: false)
      add(:edited_response, :text)
      add(:metadata, :map, default: %{})

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create(index(:user_signals, [:inference_event_id]))
    create(index(:user_signals, [:signal_type]))
  end
end
