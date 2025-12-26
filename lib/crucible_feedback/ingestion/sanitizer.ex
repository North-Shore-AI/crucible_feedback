defmodule CrucibleFeedback.Ingestion.Sanitizer do
  @moduledoc """
  Sanitize PII from inference events before storage.
  """

  @email_regex ~r/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/
  @phone_regex ~r/(\+?1[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}/
  @ssn_regex ~r/\d{3}-\d{2}-\d{4}/
  @credit_card_regex ~r/\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}/

  @doc """
  Sanitize prompt/response fields and hash user identifiers.
  """
  @spec sanitize(map()) :: map()
  def sanitize(event) do
    event
    |> sanitize_field(:prompt)
    |> sanitize_field(:response)
    |> hash_user_id()
  end

  defp sanitize_field(event, field) do
    value = Map.get(event, field, "")

    sanitized =
      patterns()
      |> Enum.reduce(value, fn {regex, replacement}, acc ->
        Regex.replace(regex, acc, replacement)
      end)

    Map.put(event, field, sanitized)
  end

  defp patterns do
    custom =
      Application.get_env(:crucible_feedback, :sanitizer, []) |> Keyword.get(:pii_patterns, [])

    [
      {@email_regex, "[EMAIL]"},
      {@phone_regex, "[PHONE]"},
      {@ssn_regex, "[SSN]"},
      {@credit_card_regex, "[CREDIT_CARD]"}
      | custom
    ]
  end

  defp hash_user_id(%{user_id: user_id} = event) when is_binary(user_id) do
    hash = :crypto.hash(:sha256, user_id) |> Base.encode16(case: :lower) |> binary_part(0, 16)

    event
    |> Map.delete(:user_id)
    |> Map.put(:user_id_hash, hash)
  end

  defp hash_user_id(event) do
    event
    |> Map.delete(:user_id)
    |> Map.put(:user_id_hash, nil)
  end
end
