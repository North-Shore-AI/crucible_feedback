defmodule CrucibleFeedback do
  @moduledoc """
  Production feedback loop for ML systems.

  ## Database Configuration

  CrucibleFeedback requires a Repo for persistence when using the Ecto storage backend.
  Configure it in your host application:

      config :crucible_feedback, repo: MyApp.Repo

  Then start your Repo in your supervision tree. Run migrations:

      mix crucible_feedback.install

  Or copy migrations from `deps/crucible_feedback/priv/repo/migrations/`.
  """

  alias CrucibleFeedback.{Curation, Drift, Export, Ingestion, Quality, Signals, Triggers}

  @doc """
  Returns the configured Repo module.

  Raises if not configured. Configure with:

      config :crucible_feedback, repo: MyApp.Repo
  """
  @spec repo() :: module()
  def repo do
    Application.get_env(:crucible_feedback, :repo) ||
      raise ArgumentError, """
      CrucibleFeedback requires a :repo configuration when using Ecto storage.

      Add to your config:

          config :crucible_feedback, repo: MyApp.Repo
      """
  end

  @type drift_result :: Drift.drift_result()

  @doc """
  Log an inference event for asynchronous ingestion.
  """
  @spec log_inference(map()) :: :ok
  def log_inference(event) do
    Ingestion.log_inference(event)
  end

  @doc """
  Record a user signal.
  """
  @spec record_signal(String.t(), atom(), map()) :: {:ok, map()} | {:error, term()}
  def record_signal(inference_id, signal_type, metadata \\ %{}) do
    Signals.record_signal(inference_id, signal_type, metadata)
  end

  @doc """
  Record a user edit signal.
  """
  @spec record_user_edit(String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def record_user_edit(inference_id, edited_response) do
    Signals.record_user_edit(inference_id, edited_response)
  end

  @doc """
  Assess quality for a single event.
  """
  @spec assess_quality(map()) :: %{score: float(), checks: list()}
  def assess_quality(event) do
    Quality.assess(event)
  end

  @doc """
  Return summary quality statistics for a deployment.
  """
  @spec get_quality_stats(String.t()) :: map()
  def get_quality_stats(deployment_id) do
    %{rolling_average: Quality.rolling_average(deployment_id)}
  end

  @doc """
  Detect drift for a deployment.
  """
  @spec detect_drift(String.t(), keyword()) :: [drift_result()]
  def detect_drift(deployment_id, opts \\ []) do
    Drift.detect(deployment_id, opts)
  end

  @doc """
  Return persisted drift history (if configured).
  """
  @spec get_drift_history(String.t()) :: [drift_result()]
  def get_drift_history(_deployment_id) do
    []
  end

  @doc """
  Curate examples for retraining.
  """
  @spec curate(String.t(), keyword()) :: [map()]
  def curate(deployment_id, opts \\ []) do
    Curation.curate(deployment_id, opts)
  end

  @doc """
  Return count of curated examples for a deployment.
  """
  @spec get_curated_count(String.t()) :: integer()
  def get_curated_count(deployment_id) do
    storage = Application.get_env(:crucible_feedback, :storage)
    storage.count_curated_examples(deployment_id, [])
  end

  @doc """
  Check retraining triggers for a deployment.
  """
  @spec check_triggers(String.t(), keyword()) :: [{:trigger, atom()}]
  def check_triggers(deployment_id, opts \\ []) do
    Triggers.check_triggers(deployment_id, opts)
  end

  @doc """
  Export curated data for training.
  """
  @spec export(String.t(), keyword()) :: {:ok, Path.t()} | {:error, term()}
  def export(deployment_id, opts \\ []) do
    Export.export(deployment_id, opts)
  end

  @doc """
  Export preference pairs derived from user edits.
  """
  @spec export_preference_pairs(String.t(), keyword()) :: {:ok, Path.t()} | {:error, term()}
  def export_preference_pairs(deployment_id, opts \\ []) do
    Export.export_preference_pairs(deployment_id, opts)
  end
end
