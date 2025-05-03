defmodule FoodTracker.FoodTracking do
  @moduledoc """
  The FoodTracking context.
  """

  import Ecto.Query, warn: false
  require Logger

  alias FoodTracker.Repo
  alias FoodTracker.FoodTracking.FoodTrack
  alias FoodTracker.Services.{GeminiService, OllamaService, NutritionInfo}

  @doc """
  Returns the list of food_tracks.

  ## Examples

      iex> list_food_tracks()
      [%FoodTrack{}, ...]

  """
  def list_food_tracks(user_id) do
    query = from(track in FoodTrack, where: track.user_id == ^user_id)

    Repo.all(query)
    |> Enum.map(fn track ->
      %{track | date: FoodTracker.Utils.year_month_day_to_day_month_year(track.date)}
    end)
  end

  def list_food_tracks_on(date, user_id) do
    if FoodTracker.Utils.is_valid_date_string?(date) do
      query = from(track in FoodTrack, where: track.date == ^date and track.user_id == ^user_id)

      Repo.all(query)
      |> Enum.map(fn track ->
        %{track | date: FoodTracker.Utils.year_month_day_to_day_month_year(track.date)}
      end)
    else
      {:error, "Invalid date format"}
    end
  end

  @doc """
  Gets a single food_track.

  Raises `Ecto.NoResultsError` if the Food track does not exist.

  ## Examples

      iex> get_food_track!(123)
      %FoodTrack{}

      iex> get_food_track!(456)
      ** (Ecto.NoResultsError)

  """
  def get_food_track!(id), do: Repo.get!(FoodTrack, id)

  defp lookup_nutrition_info(food_name) do
    with {:error, gemini_reason} <- GeminiService.get_nutrition_info(food_name),
         {:error, ollama_reason} <- OllamaService.get_nutrition_info(food_name) do
      Logger.warning(
        "Failed to get nutrition info: Gemini: #{gemini_reason}, Ollama: #{ollama_reason}"
      )

      {:error, "Could not retrieve nutrition information"}
    end
  end

  @doc """
  Creates a food_track.

  ## Examples

      iex> create_food_track(%{field: value})
      {:ok, %FoodTrack{}}

      iex> create_food_track(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_food_track(attrs \\ %{}) do
    attrs =
      case lookup_nutrition_info(attrs["name"]) do
        {:ok, %NutritionInfo{} = nutrition_info} ->
          Map.merge(attrs, %{
            "calories" => nutrition_info.calories,
            "protein" => nutrition_info.protein
          })

        {:error, _reason} ->
          Map.merge(attrs, %{
            "calories" => "Unavailable",
            "protein" => "Unavailable"
          })
      end

    %FoodTrack{}
    |> FoodTrack.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a food_track.

  ## Examples

      iex> update_food_track(food_track, %{field: new_value})
      {:ok, %FoodTrack{}}

      iex> update_food_track(food_track, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_food_track(%FoodTrack{} = food_track, attrs) do
    food_track
    |> FoodTrack.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a food_track.

  ## Examples

      iex> delete_food_track(food_track)
      {:ok, %FoodTrack{}}

      iex> delete_food_track(food_track)
      {:error, %Ecto.Changeset{}}

  """
  def delete_food_track(%FoodTrack{} = food_track) do
    Repo.delete(food_track)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking food_track changes.

  ## Examples

      iex> change_food_track(food_track)
      %Ecto.Changeset{data: %FoodTrack{}}

  """
  def change_food_track(food_track, attrs \\ %{})

  # Handle nil case
  def change_food_track(nil, attrs) do
    change_food_track(%FoodTrack{}, attrs)
  end

  def change_food_track(%FoodTrack{} = food_track, attrs) do
    FoodTrack.changeset(food_track, attrs)
  end
end
