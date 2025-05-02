defmodule FoodTracker.Services.OllamaService do
  @moduledoc """
  Service for interacting with Ollama AI for nutrition information.
  """

  @system_prompt_calories "You are a nutritionist providing estimates for calories in foods. You must only respond with a single number representing the estimated number of kilocalories (kcal) in the given food item. If you don't know, say 'Unknown'. Always respond with a number, do not respond with your thinking steps."
  @system_prompt_protein "You are a nutritionist providing estimates for protein content in foods. You must only respond with a single number representing the estimated grams of protein in the given food item. If you don't know, say 'Unknown'. Always respond with a number, do not respond with your thinking steps."

  @doc """
  Get nutrition information for a food item using Ollama.
  Returns a map with calories and protein information.
  """
  def get_nutrition_info(food_item) do
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

    # Return the results
    %{
      calories: calories_result,
      protein: protein_result
    }
  end

  defp extract_response(response) do
    case response do
      {:ok, %{"response" => response_text, "done" => true}} ->
        String.trim(response_text)

      {:ok, %{"done" => false}} ->
        "Processing not complete"

      {:error, error} ->
        "Error: #{inspect(error)}"

      unexpected ->
        "Unexpected response: #{inspect(unexpected)}"
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
    |> String.trim()
    |> then(fn str ->
      # strip out everything inbetween <think> and </think>
      str = Regex.replace(~r/<think>.*?<\/think>/s, str, "")
      result = String.trim(str) <> " " <> unit
      IO.puts(result)
      result
    end)
  end
end
