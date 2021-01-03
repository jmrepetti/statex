defmodule Statex.Error do
  defmodule UndefinedState do
    defexception message: "undefined state"
  end
  defmodule MissingResourceForTaskState do
    defexception message: "Task State must include a Resource key"
  end
  defmodule MissingChoicesForChoiceState do
    defexception message: "Choice State must include a Choices key"
  end
end
