defmodule FoodTracker.Services.OllamaService do
  @moduledoc """
  Service for interacting with Ollama AI for nutrition information.
  """
  @behaviour FoodTracker.Services.NutritionService

  require Logger
  alias FoodTracker.Services.NutritionInfo

  @system_prompt_calories "You are a nutritionist providing estimates for calories in foods. You must only respond with a single number representing the estimated number of kilocalories (kcal) in the given food item. If you don't know, say 'Unknown'. Always respond with a number, do not respond with your thinking steps."
  @system_prompt_protein "You are a nutritionist providing estimates for protein content in foods. You must only respond with a single number representing the estimated grams of protein in the given food item. If you don't know, say 'Unknown'. Always respond with a number, do not respond with your thinking steps."

  @impl true
  def get_nutrition_info(food_item) do
    Logger.info("Fetching nutrition info from Ollama for: #{food_item}")

    calories_task =
      Task.async(fn ->
        ollama_request(
          @system_prompt_calories,
          "How many calories are in: #{food_item}?",
          "kcal",
          "calories"
        )
      end)

    protein_task =
      Task.async(fn ->
        ollama_request(
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
        Logger.error("Failed to get calories from Ollama: #{calories_error}")
        {:error, "Failed to get calories: #{calories_error}"}

      {{:ok, _calories}, {:error, protein_error}} ->
        Logger.error("Failed to get protein from Ollama: #{protein_error}")
        {:error, "Failed to get protein: #{protein_error}"}

      {{:error, calories_error}, {:error, protein_error}} ->
        Logger.error(
          "Failed to get both calories and protein from Ollama: #{calories_error}, #{protein_error}"
        )

        {:error, "Failed to get calories: #{calories_error} and protein: #{protein_error}"}
    end
  end

  defp extract_response(response) do
    case response do
      {:ok, %{"response" => response_text, "done" => true}} ->
        {:ok, String.trim(response_text)}

      {:ok, %{"done" => false}} ->
        {:error, "Processing not complete"}

      {:error, error} ->
        {:error, "Error: #{inspect(error)}"}

      unexpected ->
        {:error, "Unexpected response: #{inspect(unexpected)}"}
    end
  end

  defp ollama_request(system_prompt, prompt, unit, question) do
    client = Ollama.init()

    Ollama.completion(client,
      model: "gemma3:1b",
      system: system_prompt <> question <> " in #{unit}?",
      prompt: prompt,
      options: %{
        temperature: 0.2
      }
    )
    |> extract_response()
    |> process_response(unit)
  end

  defp process_response({:ok, response_text}, _) do
    processed_text =
      response_text
      |> String.trim()
      |> remove_thinking_parts()

    {:ok, processed_text}
  end

  defp process_response({:error, reason}, _unit) do
    {:error, reason}
  end

  defp remove_thinking_parts(text) do
    # Strip out everything between <think> and </think>
    Regex.replace(~r/<think>.*?<\/think>/s, text, "")
    |> String.trim()
  end
end
