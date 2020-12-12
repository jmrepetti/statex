defmodule Statex do
  @moduledoc """
  Documentation for `Statex`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Statex.hello()
      :world

  """
  def hello do
    :world
  end

  def load_json(json_string) do
    {:ok, Jason.decode!(json_string)}
  end

  def load_file(file) do
    {:ok, content} = File.read(file)
    load_json(content)
  end
end
