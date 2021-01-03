defmodule Statex.DataTestExpr do
  @data_test_expressions ["StringEquals", "StringEqualsPath", "StringLessThan", "StringLessThanPath",
  "StringGreaterThan", "StringGreaterThanPath", "StringLessThanEquals",
  "StringLessThanEqualsPath", "StringGreaterThanEquals", "StringGreaterThanEqualsPath",
  "StringMatches", "NumericEquals", "NumericEqualsPath", "NumericLessThan",
  "NumericLessThanPath", "NumericGreaterThan", "NumericGreaterThanPath",
  "NumericLessThanEquals", "NumericLessThanEqualsPath", "NumericGreaterThanEquals",
  "NumericGreaterThanEqualsPath", "BooleanEquals", "BooleanEqualsPath", "TimestampEquals",
  "TimestampEqualsPath", "TimestampLessThan", "TimestampLessThanPath", "TimestampGreaterThan",
  "TimestampGreaterThanPath", "TimestampLessThanEquals", "TimestampLessThanEqualsPath",
  "TimestampGreaterThanEquals", "TimestampGreaterThanEqualsPath", "IsNull", "IsPresent",
  "IsNumeric", "IsString", "IsBoolean", "IsTimestamp"]

  def is_data_test_expression?(string) do
    Enum.member?(@data_test_expressions, string)
  end

  # StringEquals, StringEqualsPath
  def test_expression(_input, value, spec, "StringEquals") do
    value == spec
  end

  def test_expression(input, value, spec_path, "StringEqualsPath") do
    case ExJSONPath.eval(input, spec_path) do
      { :ok, [result] } ->  value == result
      _ -> false
    end

  end

  # StringLessThan, StringLessThanPath
  # TODO: validate spec type, in this case must be and integer
  def test_expression(_input, value, spec, "StringLessThan") do
    String.length(value) < spec
  end

  def test_expression(input, value, spec_path, "StringLessThanPath") do
    case ExJSONPath.eval(input, spec_path) do
      { :ok, [result] } -> String.length(value) < result
      _ -> false
    end
  end

  # StringGreaterThan, StringGreaterThanPath
  def test_expression(_input, value, spec, "StringGreaterThan") do
    String.length(value) > spec
  end

  def test_expression(input, value, spec_path, "StringGreaterThanPath") do
    case ExJSONPath.eval(input, spec_path) do
      { :ok, [result] } ->  String.length(value) > result
      _ -> false
    end
  end

  # StringLessThanEquals, StringLessThanEqualsPath
  def test_expression(_input, value, spec, "StringLessThanEquals") do
    String.length(value) <= spec
  end

  def test_expression(input, value, spec_path, "StringLessThanEqualsPath") do
    case ExJSONPath.eval(input, spec_path) do
      { :ok, [result] } ->  String.length(value) <= result
        _ -> false
    end
  end

  # StringGreaterThanEquals, StringGreaterThanEqualsPath
  def test_expression(_input, value, spec, "StringLessThanEquals") do
    String.length(value) >= spec
  end

  def test_expression(input, value, spec_path, "StringLessThanEqualsPath") do
    case ExJSONPath.eval(input, spec_path) do
      { :ok, [result] } -> String.length(value) >= result
        _ -> false
    end

  end

  # StringMatches
  def test_expression(_input, value, spec, "StringMatches") do
    String.match?(value, ~r/s#{spec}/)
  end

  # NumericEquals, NumericEqualsPath
  def test_expression(_input, value, spec, "NumericEquals") do
    value == spec
  end

  def test_expression(input, value, spec_path, "NumericEqualsPath") do
    case ExJSONPath.eval(input, spec_path) do
      { :ok, [result] } ->  value == result
      _ -> false
    end

  end

  # NumericLessThan, NumericLessThanPath
  def test_expression(_input, value, spec, "NumericLessThan") do
    value < spec
  end

  def test_expression(input, value, spec_path, "NumericLessThanPath") do
    case ExJSONPath.eval(input, spec_path) do
      { :ok, [result] } ->  value < result
      _ -> false
    end

  end

  # NumericGreaterThan, NumericGreaterThanPath
  def test_expression(_input, value, spec, "NumericGreaterThan") do
    value > spec
  end

  def test_expression(input, value, spec_path, "NumericGreaterThanPath") do
    case ExJSONPath.eval(input, spec_path) do
      { :ok, [result] } -> value > result
      _ -> false
    end
  end

  # NumericLessThanEquals, NumericLessThanEqualsPath
  def test_expression(_input, value, spec, "NumericLessThanEquals") do
    value <= spec
  end

  def test_expression(input, value, spec_path, "NumericLessThanEqualsPath") do
    case ExJSONPath.eval(input, spec_path) do
      { :ok, [result] } ->  value <= result
      _ -> false
    end

  end

  # NumericGreaterThanEquals, NumericGreaterThanEqualsPath
  def test_expression(_input, value, spec, "NumericGreaterThanEquals") do
    value >= spec
  end

  def test_expression(input, value, spec_path, "NumericGreaterThanEqualsPath") do
    case ExJSONPath.eval(input, spec_path) do
      { :ok, [result] } ->  value >= result
      _ -> false
    end

  end

  # BooleanEquals, BooleanEqualsPath
  def test_expression(_input, value, spec, "BooleanEquals") do
    value == spec
  end

  def test_expression(input, value, spec_path, "BooleanEqualsPath") do
    case ExJSONPath.eval(input, spec_path) do
      { :ok, [result] } ->  value == result
      _ -> false
    end

  end

  #TODO: TimestampEquals, TimestampEqualsPath

  #TODO: TimestampLessThan, TimestampLessThanPath

  #TODO: TimestampGreaterThan, TimestampGreaterThanPath

  #TODO: TimestampLessThanEquals, TimestampLessThanEqualsPath

  #TODO: TimestampGreaterThanEquals, TimestampGreaterThanEqualsPath

  # IsNull
  def test_expression(_input, value, _spec, "IsNull") do
    value == nil
  end


  # IsPresent
  # TODO: Note: In this case, if the Variable-field Path fails to match anything in the input no exception is thrown and the Choice Rule just returns false.
  def test_expression(_input, value, spec, "IsPresent") do
    (value != nil) == spec
  end

  # IsNumeric
  def test_expression(_input, value, spec, "IsNumeric") do
    is_number(value) == spec
  end

  # IsString
  def test_expression(_input, value, spec, "IsString") do
    is_binary(value) == spec
  end

  # IsBoolean
  def test_expression(_input, value, spec, "IsBoolean") do
    (value == true || value == false) == spec
  end

  #TODO: IsTimestamp
end
