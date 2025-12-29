defmodule CrucibleFeedback.Application do
  @moduledoc """
  OTP application for CrucibleFeedback.
  """

  use Application

  @impl true
  @doc false
  def start(_type, _args) do
    storage = Application.get_env(:crucible_feedback, :storage)
    start_repo = Application.get_env(:crucible_feedback, :start_repo, false)
    start_ingestion = Application.get_env(:crucible_feedback, :start_ingestion, true)

    children =
      []
      |> maybe_add_repo(start_repo)
      |> maybe_add_storage(storage)
      |> maybe_add_ingestion(start_ingestion, storage)

    opts = [strategy: :one_for_one, name: CrucibleFeedback.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp maybe_add_repo(children, true), do: children ++ [CrucibleFeedback.Repo]
  defp maybe_add_repo(children, _), do: children

  defp maybe_add_storage(children, CrucibleFeedback.Storage.Memory) do
    children ++ [CrucibleFeedback.Storage.Memory]
  end

  defp maybe_add_storage(children, _storage), do: children

  defp maybe_add_ingestion(children, true, storage) do
    ingestion_opts = Application.get_env(:crucible_feedback, :ingestion, [])
    children ++ [{CrucibleFeedback.Ingestion, Keyword.put(ingestion_opts, :storage, storage)}]
  end

  defp maybe_add_ingestion(children, _start, _storage), do: children
end
