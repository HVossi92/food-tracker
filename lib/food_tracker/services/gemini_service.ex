defmodule FoodTracker.Services.GeminiService do
  @moduledoc """
  Service for interacting with Google's Gemini API for nutrition information.
  """

  @system_prompt_calories "You are a nutritionist providing estimates for calories in foods. You must only respond with a single number representing the estimated number of kilocalories (kcal) in the given food item. If you don't know, say 'Unknown'. Always respond with a number, do not respond with your thinking steps."
  @system_prompt_protein "You are a nutritionist providing estimates for protein content in foods. You must only respond with a single number representing the estimated grams of protein in the given food item. If you don't know, say 'Unknown'. Always respond with a number, do not respond with your thinking steps."

  # Get configuration from application config
  defp gemini_url, do: Application.get_env(:food_tracker, :gemini_api)[:url]
  defp api_key, do: Application.get_env(:food_tracker, :gemini_api)[:api_key]

  @doc """
  Get nutrition information for a food item using Gemini API.
  Returns {:ok, %{calories: string, protein: string}} on success
  or {:error, reason} on failure.
  """
  def get_nutrition_info(food_item) do
    IO.puts("Gemini")

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
        {:ok, %{calories: calories, protein: protein}}

      {{:error, calories_error}, {:ok, _protein}} ->
        {:error, "Failed to get calories: #{calories_error}"}

      {{:ok, _calories}, {:error, protein_error}} ->
        {:error, "Failed to get protein: #{protein_error}"}

      {{:error, calories_error}, {:error, protein_error}} ->
        {:error, "Failed to get calories: #{calories_error} and protein: #{protein_error}"}
    end
  end

  defp gemini_request(system_prompt, prompt, unit, _question) do
    url = "#{gemini_url()}?key=#{api_key()}"

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
        IO.puts("Error: #{error_message}")
        {:error, error_message}

      {:error, reason} ->
        IO.puts("Error: #{inspect(reason)}")
        {:error, inspect(reason)}
    end
  end

  defp process_response(body, unit) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        case decoded do
          %{"candidates" => [%{"content" => %{"parts" => [%{"text" => text} | _]}} | _]} ->
            processed_text =
              text
              |> String.trim()
              |> remove_thinking_parts()
              |> append_unit(unit)

            {:ok, processed_text}

          _ ->
            {:error, "Unexpected response format from Gemini API"}
        end

      {:error, reason} ->
        {:error, "Could not decode JSON response: #{inspect(reason)}"}
    end
  end

  defp remove_thinking_parts(text) do
    # Strip out everything between <think> and </think>
    Regex.replace(~r/<think>.*?<\/think>/s, text, "")
    |> String.trim()
  end

  defp append_unit(text, unit) do
    text <> " " <> unit
  end
end
