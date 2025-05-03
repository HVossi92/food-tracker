defmodule FoodTracker.Services.NutritionService do
  @moduledoc """
  Behavior module defining the contract for nutrition information services.
  """

  @type nutrition_info :: %{
          calories: String.t(),
          protein: String.t()
        }

  @callback get_nutrition_info(String.t()) :: {:ok, nutrition_info()} | {:error, String.t()}
end
