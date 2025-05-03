defmodule FoodTracker.Services.NutritionInfo do
  @moduledoc """
  Struct representing nutrition information for a food item.
  """

  @type t :: %__MODULE__{
          calories: String.t(),
          protein: String.t()
        }

  defstruct [:calories, :protein]
end
