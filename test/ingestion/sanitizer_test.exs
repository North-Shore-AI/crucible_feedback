defmodule CrucibleFeedback.Ingestion.SanitizerTest do
  use ExUnit.Case, async: true

  alias CrucibleFeedback.Ingestion.Sanitizer

  test "masks common PII patterns and hashes user_id" do
    event = %{
      user_id: "user-123",
      prompt: "email a@b.com phone 555-123-4567 ssn 123-45-6789",
      response: "card 4111 1111 1111 1111 and 4111-1111-1111-1111"
    }

    sanitized = Sanitizer.sanitize(event)

    assert sanitized.user_id_hash != nil
    refute Map.has_key?(sanitized, :user_id)
    assert sanitized.prompt =~ "[EMAIL]"
    assert sanitized.prompt =~ "[PHONE]"
    assert sanitized.prompt =~ "[SSN]"
    assert sanitized.response =~ "[CREDIT_CARD]"
  end

  test "supports custom PII patterns via config" do
    Application.put_env(:crucible_feedback, :sanitizer,
      pii_patterns: [{~r/SECRET\d+/, "[SECRET]"}]
    )

    on_exit(fn ->
      Application.put_env(:crucible_feedback, :sanitizer, pii_patterns: [])
    end)

    event = %{prompt: "SECRET123", response: "clean"}
    sanitized = Sanitizer.sanitize(event)

    assert sanitized.prompt == "[SECRET]"
  end

  test "sets user_id_hash to nil when user_id missing" do
    sanitized = Sanitizer.sanitize(%{prompt: "hello", response: "world"})
    assert Map.get(sanitized, :user_id_hash) == nil
  end
end
