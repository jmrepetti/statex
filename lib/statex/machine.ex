defmodule Statex.Machine do
  def start(machine, input \\ %{}) do
    enter_state(machine["StartAt"], input, machine)
  end

  # InputPath |> Parameters |> effective input
  # ResultSelector |>  effective result
  # ResultPath |> OutputPath |> effective output
  def enter_state(state_name, state_input, machine) do
    case machine["States"][state_name] do
      nil -> raise Statex.Error.UndefinedState, message: "undefined state: #{state_name}"
      state ->
        state
        |> Map.put("Input", state_input)
        |> input_preprocess
        |> handle_state
        |> result_postprocess(state_input)
        |> transition(machine)
    end
  end

  def transition(state, machine) do
    cond do
      state["End"] -> state["Result"]
      state["Next"] -> enter_state(state["Next"], state["Result"], machine)
    end
  end

  def handle_state(state) do
    case state["Type"] do
      "Task" -> handle_task_state(state)
      "Pass" -> handle_pass_state(state)
      "Choice" -> handle_choices_state(state)
      _ -> "no f idea"
    end
  end

  def input_preprocess(state) do
    state
    |> filter_path("Input", state["InputPath"]) #
    |> filter_template("Input", state["Parameters"]) # Pass selected data from input
  end

  def result_postprocess(state, state_initial_input) do
    state
    |> filter_template("Result", state["ResultSelector"]) #select data from result as result
    |> result_path(state_initial_input, state["ResultPath"]) # merge result with state input
    |> filter_path("Result", state["OutputPath"]) # Pass selected data to next state
  end

  def handle_choices_state(state) do
    state
    |> handle_choices(state["Choices"])
  end

  def handle_task_state(state) do
    state
    |> handle_resource(state["Resource"])
  end

  def handle_pass_state(state) do
    state
  end

  def filter_path(state, _key, nil) do
    state
  end

  def filter_path(state, key, template) do
    { :ok, [result] } = ExJSONPath.eval(state[key], template)
    Map.put(state, key, result)
  end

  def filter_template(state, _key , nil) do
    state
  end

  def filter_template(state, key, template) do
    filtered = Enum.map(template, fn {k, v} ->
      cond do
        String.ends_with?(k, ".$") ->
          { :ok, [result] } = ExJSONPath.eval(state[key], v)
          { String.replace_suffix(k, ".$", ""), result }
        true ->
          {k,v}
      end
    end) |>  Map.new
    Map.put(state, key, filtered)
  end

  def result_path(result, _raw_input, nil) do
    result
  end

  # TODO: this is a happy function
  def result_path(state, state_initial_input, path) do
    path_list = path
      |> String.replace_prefix("$.", "")
      |> String.split(".")
    merged_input_result = put_in(state_initial_input, path_list, state["Result"])
    Map.put(state, "Result", merged_input_result)
  end

  def handle_resource(_state, nil) do
    raise Statex.Error.MissingResourceForTaskState
  end

  def handle_resource(state, resource) do
    # TODO: provide other resources handlers like uris
    [_handler, module_string, fn_name] = String.split(resource, ":")
    module = String.to_existing_atom("Elixir.#{module_string}")
    result = apply(module, String.to_atom(fn_name), [state["Input"]])
    Map.put(state, "Result", result)
  end

  def handle_choices(_state, nil) do
    raise Statex.Error.MissingChoicesForChoiceState
  end

  def handle_choices(state, choices) do
    matching_rule = Enum.find(choices, fn(choice_rule) ->
      test_choice_rule(state, choice_rule)
    end)
    if matching_rule do
      Map.put(state, "Next", matching_rule["Next"])
    else
      Map.put(state, "Next", state["Default"])
    end
  end

  # TODO: consider moving choices logic to a different module
  def test_choice_rule(state, choice_rule) do
    cond do
      choice_rule["Not"] -> test_not_rule(state, choice_rule["Not"])
      choice_rule["And"] -> test_and_rule(state, choice_rule["And"])
      choice_rule["Or"] -> test_or_rule(state, choice_rule["Or"])
      true -> test_data_test_rule(state, choice_rule)
    end
  end

  def value_from_path(map, template) do
    case ExJSONPath.eval(map, template) do
      { :ok, [result] } -> result
      _ -> nil
    end
  end

  def test_not_rule(state, choice_rule) do
    !test_data_test_rule(state, choice_rule)
  end

  def test_and_rule(input, choices) do
    Enum.all?(choices, fn choice ->
      test_data_test_rule(input, choice)
    end)
  end

  def test_or_rule(input, choices) do
    Enum.any?(choices, fn choice ->
      test_data_test_rule(input, choice)
    end)
  end

  def test_data_test_rule(state, choice_rule) do
    # map choice_rule to a {Value,Spec{ExprName,ExpeVal}} map
    map_choice_rule = Enum.map(choice_rule, fn {k, v} ->
      cond do
        k == "Variable" ->
          { "Value", value_from_path(state["Input"], v) }
        Statex.DataTestExpr.is_data_test_expression?(k) ->
          { "Spec", %{"ExprName" => k, "ExpeVal" => v} }
        true ->
          {k,v}
      end
    end) |>  Map.new

    Statex.DataTestExpr.test_expression(state["Input"],
      map_choice_rule["Value"],
      map_choice_rule["Spec"]["ExpeVal"],
      map_choice_rule["Spec"]["ExprName"])
  end
  # Terminal State (Succeed, Fail, or an End State) or a runtime error occurs.

end
