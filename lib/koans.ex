defmodule Koans.MeditateWarning do
  defexception [:message]
  def message(exception) do
    # TODO include offending line of code in output
    formatted_message = IO.ANSI.format([:magenta, :bright, "Please meditate: ", :blue, exception.message])
    "#{formatted_message}"
  end
end

defmodule Koans do
  @name __MODULE__

  defmacro __using__([]) do
    quote do
      import ExUnit.Assertions
      import Koans, only: [think: 2, stop_to_learn: 3, meditate: 1, __?: 0, assert_?: 1]
    end
  end

  def start do
    Agent.start_link(fn -> [] end, name: @name)
    System.at_exit(fn 0 -> run end)
  end

  def add(koan) do
    Agent.update(@name, fn koans -> [koan|koans] end)
  end

  defp get do
    Agent.get(@name, fn koans -> koans end)
  end

  def run do
    get |> Enum.reverse |> Enum.each(&exec/1)
  end

  defp exec({module, koan}) do
    # TODO
  end

  defmacro think(message, lesson) do
    quote do
      Module.put_attribute(__MODULE__, :meditation, unquote(message))
      try do
        unquote(lesson)
      rescue
        lesson in [ExUnit.AssertionError, Koans.MeditateWarning] ->
          stop_to_learn(lesson, @meditation, __MODULE__)
      end
      # TODO congratulate success
    end
  end

  def stop_to_learn(error, meditation, case) do
    Koans.Formatter.failure_message(error, meditation, case)
    |> IO.puts
    exit(:shutdown)
  end

  def meditate(subject) do
    raise Koans.MeditateWarning, message: subject
  end

  defmacro __? do
    quote do
      meditate @meditation
    end
  end

  defmacro assert_?(_ \\ nil) do
    quote do
      meditate @meditation <> "#{IO.ANSI.format([:red, " (replace with an assertion)"])}"
    end
  end
end
