defmodule FoodTracker.Services.NutritionInfo do
  @moduledoc """
  Struct representing nutrition information for a food item.
  """

  @type t :: %__MODULE__{
          calories: float(),
          protein: float()
        }

  defstruct [:calories, :protein]
end
