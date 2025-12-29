defmodule CrucibleFeedback.RepoConfigTest do
  use ExUnit.Case, async: false

  alias CrucibleFeedback.Storage.Ecto, as: EctoStorage

  defmodule RepoStub do
    def all(query) do
      send(self(), {:repo_all, query})
      []
    end
  end

  setup do
    original = Application.get_env(:crucible_feedback, :repo)

    on_exit(fn ->
      if is_nil(original) do
        Application.delete_env(:crucible_feedback, :repo)
      else
        Application.put_env(:crucible_feedback, :repo, original)
      end
    end)

    :ok
  end

  test "repo/0 returns configured repo" do
    Application.put_env(:crucible_feedback, :repo, RepoStub)

    assert CrucibleFeedback.repo() == RepoStub
  end

  test "repo/0 raises when missing" do
    Application.delete_env(:crucible_feedback, :repo)

    assert_raise ArgumentError, ~r/:repo configuration/, fn ->
      CrucibleFeedback.repo()
    end
  end

  test "ecto storage uses configured repo" do
    Application.put_env(:crucible_feedback, :repo, RepoStub)

    assert EctoStorage.list_events("deploy-1", []) == []
    assert_received {:repo_all, _query}
  end
end
