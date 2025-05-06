defmodule FoodTracker.Services.GeminiService do
  @moduledoc """
  Service for interacting with Google's Gemini API for nutrition information.
  """
  @behaviour FoodTracker.Services.NutritionService

  require Logger
  alias FoodTracker.Services.NutritionInfo
  alias FoodTracker.Services.TextProcessing

  @system_prompt_calories "You are a nutritionist providing estimates for calories in foods. You must only respond with a single number representing the estimated number of kilocalories (kcal) in the given food item. If you don't know, say 'Unknown'. Always respond with a number, do not respond with your thinking steps."
  @system_prompt_protein "You are a nutritionist providing estimates for protein content in foods. You must only respond with a single number representing the estimated grams of protein in the given food item. If you don't know, say 'Unknown'. Always respond with a number, do not respond with your thinking steps."

  # Get configuration from application config
  defp gemini_url, do: Application.get_env(:food_tracker, :gemini_api)[:url]

  defp api_key do
    key = Application.get_env(:food_tracker, :gemini_api)[:api_key]

    if is_nil(key) || key == "" do
      Logger.error("Gemini API key is not set or empty. Check your configuration.")
      nil
    else
      key
    end
  end

  @impl true
  def get_nutrition_info(food_item) do
    Logger.info("Fetching nutrition info from Gemini for: #{food_item}")

    calories_task =
      Task.async(fn ->
        gemini_request(
          @system_prompt_calories,
          "How many calories are in: #{food_item}?",
          "kcal",
          "calories"
        )
      end)

    protein_task =
      Task.async(fn ->
        gemini_request(
          @system_prompt_protein,
          "How much protein is in: #{food_item}?",
          "grams",
          "protein"
        )
      end)

    # Wait for tasks to complete with a 30-second timeout
    calories_result = Task.await(calories_task, 32_000)
    protein_result = Task.await(protein_task, 32_000)

    # Handle results based on whether they were successful or not
    case {calories_result, protein_result} do
      {{:ok, calories}, {:ok, protein}} ->
        {:ok, %NutritionInfo{calories: calories, protein: protein}}

      {{:error, calories_error}, {:ok, _protein}} ->
        Logger.error("Failed to get calories from Gemini: #{calories_error}")
        {:error, "Failed to get calories: #{calories_error}"}

      {{:ok, _calories}, {:error, protein_error}} ->
        Logger.error("Failed to get protein from Gemini: #{protein_error}")
        {:error, "Failed to get protein: #{protein_error}"}

      {{:error, calories_error}, {:error, protein_error}} ->
        Logger.error(
          "Failed to get both calories and protein from Gemini: #{calories_error}, #{protein_error}"
        )

        {:error, "Failed to get calories: #{calories_error} and protein: #{protein_error}"}
    end
  end

  defp gemini_request(system_prompt, prompt, unit, _question) do
    api_key = api_key()

    if is_nil(api_key) do
      {:error, "Gemini API key is not configured"}
    else
      url = "#{gemini_url()}?key=#{api_key}"

      # Build the request payload
      payload = %{
        contents: [
          %{
            parts: [
              %{
                text: system_prompt <> "\n\n" <> prompt
              }
            ]
          }
        ],
        generation_config: %{
          temperature: 0.2
        }
      }

      # Convert the payload to JSON
      {:ok, json_payload} = Jason.encode(payload)

      # Make the HTTP request
      case :post
           |> Finch.build(
             url,
             [{"Content-Type", "application/json"}],
             json_payload
           )
           |> Finch.request(FoodTracker.Finch) do
        {:ok, %Finch.Response{status: 200, body: body}} ->
          process_response(body, unit)

        {:ok, %Finch.Response{status: status, body: body}} ->
          error_message = "HTTP error: #{status}, #{body}"
          Logger.error(error_message)
          {:error, error_message}

        {:error, reason} ->
          Logger.error("Request error: #{inspect(reason)}")
          {:error, inspect(reason)}
      end
    end
  end

  defp process_response(body, _) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        case decoded do
          %{"candidates" => [%{"content" => %{"parts" => [%{"text" => text} | _]}} | _]} ->
            cleaned_value = TextProcessing.extract_numbers(text)

            if cleaned_value == -1.0 do
              {:error, "Gemini could not provide a numeric answer"}
            else
              {:ok, cleaned_value}
            end

          _ ->
            {:error, "Unexpected response format from Gemini API"}
        end

      {:error, reason} ->
        {:error, "Could not decode JSON response: #{inspect(reason)}"}
    end
  end
end
