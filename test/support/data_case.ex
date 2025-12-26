defmodule CrucibleFeedback.DataCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias CrucibleFeedback.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import CrucibleFeedback.DataCase
    end
  end

  setup tags do
    if Application.get_env(:crucible_feedback, :start_repo, false) do
      :ok = Sandbox.checkout(CrucibleFeedback.Repo)

      unless tags[:async] do
        Sandbox.mode(CrucibleFeedback.Repo, {:shared, self()})
      end
    end

    :ok
  end
end
