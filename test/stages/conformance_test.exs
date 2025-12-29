defmodule CrucibleFeedback.Stages.ConformanceTest do
  @moduledoc """
  Conformance tests for CrucibleFeedback stages.

  Verifies all stages implement the describe/1 contract correctly
  with the canonical schema format.
  """
  use ExUnit.Case

  alias CrucibleFeedback.Stages.{
    CheckTriggers,
    ExportFeedback
  }

  @stages [
    ExportFeedback,
    CheckTriggers
  ]

  describe "all feedback stages implement describe/1" do
    for stage <- @stages do
      test "#{inspect(stage)} has describe/1" do
        assert function_exported?(unquote(stage), :describe, 1)
      end

      test "#{inspect(stage)} returns valid schema" do
        schema = unquote(stage).describe(%{})
        assert is_atom(schema.name)
        assert is_binary(schema.description)
        assert is_list(schema.required)
        assert is_list(schema.optional)
        assert is_map(schema.types)
      end

      test "#{inspect(stage)} has types for all optional fields" do
        schema = unquote(stage).describe(%{})

        for key <- schema.optional do
          assert Map.has_key?(schema.types, key),
                 "Optional field #{key} missing from types"
        end
      end

      test "#{inspect(stage)} has no overlap between required and optional" do
        schema = unquote(stage).describe(%{})

        overlap =
          MapSet.intersection(
            MapSet.new(schema.required),
            MapSet.new(schema.optional)
          )

        assert MapSet.size(overlap) == 0
      end
    end
  end

  describe "stage-specific schemas" do
    test "export_feedback has expected schema" do
      schema = ExportFeedback.describe(%{})
      assert schema.name == :export_feedback
      assert :format in schema.optional
      assert :output_path in schema.optional
      assert schema.types.format == {:enum, [:jsonl, :parquet, :csv]}
    end

    test "check_triggers has expected schema" do
      schema = CheckTriggers.describe(%{})
      assert schema.name == :check_triggers
      assert :threshold in schema.optional
      assert :window_hours in schema.optional
      assert :trigger_types in schema.optional

      assert schema.types.trigger_types ==
               {:list, {:enum, [:drift, :accuracy, :volume, :feedback]}}
    end
  end
end
