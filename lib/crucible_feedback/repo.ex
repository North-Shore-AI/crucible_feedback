defmodule CrucibleFeedback.Repo do
  @moduledoc """
  Ecto repository for CrucibleFeedback.
  """

  use Ecto.Repo,
    otp_app: :crucible_feedback,
    adapter: Ecto.Adapters.Postgres
end
