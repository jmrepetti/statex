defmodule Statex.Machine do
  def start(machine, input \\ %{}) do
    enter_state(input, machine["StartAt"], machine)
  end

  def enter_state(input, true, _machine) do
    input
  end

  def enter_state(input, state, machine) do
    case machine["States"][state] do
      nil -> raise Statex.Error.UndefinedState, message: "undefined state: #{state}"
      state_definition -> handle_state(input, state_definition, machine)
    end
  end

  def transition(input, state, machine) do
    cond do
      state["End"] -> input
      state["Next"] -> enter_state(input, state["Next"], machine)
    end
  end

  def enter_state(input, state, machine) do
    handle_state(input, machine["States"][state], machine)
  end

  def handle_state(input, state, machine) do
    case state["Type"] do
      "Task" -> handle_task(state, machine, input)
      _ -> "no f idea"
    end
  end

  # InputPath |> Parameters |> effective input
  # ResultSelector |>  effective result
  # ResultPath |> OutputPath |> effective output
  def handle_task(state, machine, input) do
      input
      |> filter_path(state["InputPath"]) #
      |> filter_template(state["Parameters"]) # Pass selected data from input
      |> handle_resource(state["Resource"])
      |> filter_template(state["ResultSelector"]) #select data from result
      |> result_path(input, state["ResultPath"]) # insert result into input body
      |> filter_path(state["OutputPath"]) # Pass selected data to next state
      |> transition(state, machine)
  end


  def filter_path(input, nil) do
    input
  end

  def filter_path(input, template) do
    { :ok, [result] } = ExJSONPath.eval(input, template)
    result
  end

  def filter_template(input, nil) do
    input
  end

  def filter_template(input, template) do
    Enum.map(template, fn {k, v} ->
      cond do
        String.ends_with?(k, ".$") ->
          { :ok, [result] } = ExJSONPath.eval(input, v)
          { String.replace_suffix(k, ".$", ""), result }
        true ->
          {k,v}
      end
    end) |>  Map.new
  end

  def result_path(result, _raw_input, nil) do
    result
  end

  # TODO: this is a happy function
  def result_path(result, raw_input, path) do
    path_list = path
      |> String.replace_prefix("$.", "")
      |> String.split(".")
    put_in(raw_input, path_list, result)
  end

  def handle_resource(input, resource) do
    # TODO: provide other resources handlers like uris
    [_handler, module_string, fn_name] = String.split(resource, ":")
    module = String.to_existing_atom("Elixir.#{module_string}")
    apply(module, String.to_atom(fn_name), [input])
  end

  # Terminal State (Succeed, Fail, or an End State) or a runtime error occurs.

end
