defmodule StatexTest do
  use ExUnit.Case
  doctest Statex

  # def add(args), do: IO.puts(args)
  def add(args), do: args["X"] + args["Y"]
  def pow2(arg), do: arg * arg

  test "greets the world" do
    assert Statex.hello() == :world
  end

  test "filter_path" do
    assert %{"Input" => 42} == Statex.Machine.filter_path(%{"Input" => %{"X" => 1, "Y" => 42}}, "Input", "$.Y")
  end

  test "filter_path nested" do
    assert %{"Input" => 42} == Statex.Machine.filter_path(%{"Input" => %{"X" => 1, "Y" => %{"Z" => 42}}}, "Input", "$.Y.Z")
  end

  test "filter_template" do
    state = %{"Input" => %{"X" => 1, "Y" => %{"Z" => 42}}}

    template = %{
      "A.$" => "$.X",
      "B.$" => "$.Y.Z"
    }

    result = %{"Input" => %{
      "A" => 1,
      "B" => 42
    }}

    assert result == Statex.Machine.filter_template(state, "Input", template)
  end

  test "hello world machine" do
    {:ok, machine_def } = Statex.load_file("./test/support/hello_world.json")
    assert 3 == Statex.Machine.start(machine_def, %{"X" => 1, "Y" => 2})
  end

  test "two states machine" do
    {:ok, machine_def } = Statex.load_file("./test/support/two_states.json")
    assert 4 == Statex.Machine.start(machine_def, %{"numbers" => [1, 2], "SOMEKEY" => %{}})
  end

  test "pass state" do
    {:ok, machine_def } = Statex.load_file("./test/support/pass_state.json")
    input = %{"georefOf" => "Home"}
    spec_output = %{
      "georefOf" => "Home",
      "coords" => %{
        "x-datum" => 0.381018,
        "y-datum" => 622.2269926397355
      }
    }
    output = Statex.Machine.start(machine_def, input)
    assert spec_output == output
  end

  test "undefined state" do
    {:ok, machine_def } = Statex.load_file("./test/support/undefined_state.json")
    input = %{}
    assert_raise Statex.Error.UndefinedState, fn ->
      Statex.Machine.start(machine_def, input)
    end
  end

  test "choices state" do
    {:ok, machine_def } = Statex.load_file("./test/support/choices_state.json")
    input = %{
      "type" => "Private",
      "value" => 22
    }
    assert "OK" == Statex.Machine.start(machine_def, input)
  end

  test "choices state no match" do
    {:ok, machine_def } = Statex.load_file("./test/support/choices_state_no_match.json")
    input = %{
      "type" => "Private",
      "value" => 22
    }
    assert "KO" == Statex.Machine.start(machine_def, input)
  end

end
