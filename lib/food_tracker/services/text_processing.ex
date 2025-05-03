defmodule FoodTracker.Services.TextProcessing do
  @moduledoc """
  Helper module for text processing functions used by various services.
  """

  @doc """
  Removes thinking parts from AI responses and extracts only numerical values.

  This function:
  1. Removes any content between <think> and </think> tags
  2. Keeps only numbers and decimal points
  3. Parses the result as a float or returns -1.0 if parsing fails
  """
  def extract_numbers(text) do
    IO.puts(">>>>>>>> extract_numbers")
    # Strip out everything between <think> and </think>
    text = Regex.replace(~r/<think>.*?<\/think>/s, text, "")
    # Keep only numbers and decimal points
    numbers_only = Regex.replace(~r/[^\d\.]+/, text, "")

    case Float.parse(numbers_only) do
      {number, _} -> number
      :error -> -1.0
    end
  end
end
