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
    assert 42 == Statex.Machine.filter_path(%{"X" => 1, "Y" => 42}, "$.Y")
  end

  test "filter_path nested" do
    assert 42 == Statex.Machine.filter_path(%{"X" => 1, "Y" => %{"Z" => 42}}, "$.Y.Z")
  end

  test "filter_template" do
    input = %{"X" => 1, "Y" => %{"Z" => 42}}

    template = %{
      "A.$" => "$.X",
      "B.$" => "$.Y.Z"
    }

    result = %{
      "A" => 1,
      "B" => 42
    }

    assert result == Statex.Machine.filter_template(input, template)
  end

  test "hello world machine" do
    {:ok, machine_def } = Statex.load_file("./test/support/hello_world.json")
    assert 3 == Statex.Machine.start(machine_def, %{"X" => 1, "Y" => 2})
  end

  test "two states machine" do
    {:ok, machine_def } = Statex.load_file("./test/support/two_states.json")
    assert 4 == Statex.Machine.start(machine_def, %{"numbers" => [1, 2], "SOMEKEY" => %{}})
  end

  test "undefined state" do
    {:ok, machine_def } = Statex.load_file("./test/support/undefined_state.json")
    input = %{}
    assert_raise Statex.Error.UndefinedState, fn ->
      Statex.Machine.start(machine_def, input)
    end
  end

end
