defmodule FoodTracker.Food_Tracking do
  @moduledoc """
  The Food_Tracking context.
  """

  import Ecto.Query, warn: false
  alias FoodTracker.Repo
  alias FoodTracker.Food_Tracking.Food_Track
  alias FoodTracker.Services.OllamaService
  alias FoodTracker.Services.GeminiService

  # Define a module attribute that can be set at compile time but used at runtime
  @env Application.compile_env(:food_tracker, :env, :prod)

  @doc """
  Returns the list of food_tracks.

  ## Examples

      iex> list_food_tracks()
      [%Food_Track{}, ...]

  """
  def list_food_tracks(user_id) do
    # Early return with empty results if user_id is nil
    if is_nil(user_id) do
      []
    else
      query = from(track in Food_Track, where: track.user_id == ^user_id)

      Repo.all(query)
      |> Enum.map(fn track ->
        %{track | date: FoodTracker.Utils.year_month_day_to_day_month_year(track.date)}
      end)
    end
  end

  def list_food_tracks_on(date, user_id) do
    # Early return with empty results if user_id is nil
    if is_nil(user_id) do
      # Return an empty result set with the same structure
      %{food_tracks: [], calories: 0, protein: 0}
    else
      if FoodTracker.Utils.is_valid_date_string?(date) do
        query =
          from(track in Food_Track, where: track.date == ^date and track.user_id == ^user_id)

        rows =
          Repo.all(query)
          |> Enum.map(fn track ->
            %{track | date: FoodTracker.Utils.year_month_day_to_day_month_year(track.date)}
          end)

        {rows, total_calories, total_protein} =
          rows
          |> Enum.reduce({[], 0, 0}, fn row, {acc_rows, acc_calories, acc_protein} ->
            {acc_rows ++ [row], acc_calories + row.calories, acc_protein + row.protein}
          end)

        %{food_tracks: rows, calories: total_calories, protein: total_protein}
      else
        {:error, "Invalid date format"}
      end
    end
  end

  @doc """
  Gets a single food__track.

  Raises `Ecto.NoResultsError` if the Food  track does not exist.

  ## Examples

      iex> get_food__track!(123)
      %Food_Track{}

      iex> get_food__track!(456)
      ** (Ecto.NoResultsError)

  """

  # def get_food__track!(id), do: Repo.get!(Food_Track, id)

  @doc """
  Gets a single food__track owned by the specified user.

  Raises `Ecto.NoResultsError` if the Food track does not exist
  or does not belong to the specified user.

  ## Examples

      iex> get_food__track!(123, current_user_id)
      %Food_Track{}

      iex> get_food__track!(456, current_user_id)
      ** (Ecto.NoResultsError)
  """
  def get_food__track!(id, user_id) do
    Repo.get_by!(Food_Track, id: id, user_id: user_id)
  end

  @doc """
  Creates a food__track.

  ## Examples

      iex> create_food__track(%{field: value})
      {:ok, %Food_Track{}}

      iex> create_food__track(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_food__track(attrs \\ %{}) do
    # Skip nutrition API calls in test environment
    attrs =
      if @env == :test do
        attrs
        |> Map.put("calories", -1.0)
        |> Map.put("protein", -1.0)
      else
        # Get nutrition information from APIs
        nutrition_result = GeminiService.get_nutrition_info(attrs["name"])

        # Process the nutrition info based on whether it was successful or not
        case nutrition_result do
          {:ok, nutrition_info} ->
            IO.puts(
              ">>>>>>>> GEMINI calories: #{nutrition_info.calories}, protein #{nutrition_info.protein}"
            )

            attrs
            |> Map.put("calories", nutrition_info.calories)
            |> Map.put("protein", nutrition_info.protein)

          {:error, reason} ->
            IO.puts("Error getting nutrition info from Gemini: #{reason}")

            # Try Ollama as a fallback
            IO.puts("Trying Ollama as a fallback...")
            ollama_result = OllamaService.get_nutrition_info(attrs["name"])

            case ollama_result do
              {:ok, nutrition_info} ->
                IO.puts(
                  ">>>>>>>> OLLAMA calories: #{nutrition_info.calories}, protein #{nutrition_info.protein}"
                )

                attrs
                |> Map.put("calories", nutrition_info.calories)
                |> Map.put("protein", nutrition_info.protein)

              {:error, ollama_reason} ->
                IO.puts("Error getting nutrition info from Ollama: #{ollama_reason}")

                # Both services failed, set default values
                attrs
                |> Map.put("calories", -1.0)
                |> Map.put("protein", -1.0)
            end
        end
      end

    %Food_Track{}
    |> Food_Track.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a food__track.

  ## Examples

      iex> update_food__track(food__track, %{field: new_value})
      {:ok, %Food_Track{}}

      iex> update_food__track(food__track, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defp update_food__track(%Food_Track{} = food__track, attrs) do
    food__track
    |> Food_Track.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a food__track after verifying it belongs to the specified user.

  ## Examples

      iex> update_food__track(food_track_id, user_id, %{field: new_value})
      {:ok, %Food_Track{}}

      iex> update_food__track(food_track_id, user_id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> update_food__track(id_belonging_to_other_user, user_id, attrs)
      ** (Ecto.NoResultsError)
  """
  def update_food__track(id, user_id, attrs) do
    food__track = get_food__track!(id, user_id)
    update_food__track(food__track, attrs)
  end

  @doc """
  Deletes a food__track.

  ## Examples

      iex> delete_food__track(food__track)
      {:ok, %Food_Track{}}

      iex> delete_food__track(food__track)
      {:error, %Ecto.Changeset{}}

  """

  # def delete_food__track(%Food_Track{} = food__track) do
  #   Repo.delete(food__track)
  # end

  @doc """
  Deletes a food__track after verifying it belongs to the specified user.

  ## Examples

      iex> delete_food__track(food_track_id, user_id)
      {:ok, %Food_Track{}}

      iex> delete_food__track(id_belonging_to_other_user, user_id)
      ** (Ecto.NoResultsError)
  """
  def delete_food__track(id, user_id) do
    id
    |> get_food__track!(user_id)
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking food__track changes.

  ## Examples

      iex> change_food__track(food__track)
      %Ecto.Changeset{data: %Food_Track{}}

  """
  defp change_food__track(food__track, attrs \\ %{})

  # Handle nil case
  defp change_food__track(nil, attrs) do
    change_food__track(%Food_Track{}, attrs)
  end

  defp change_food__track(%Food_Track{} = food__track, attrs) do
    Food_Track.changeset(food__track, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking food__track changes after verifying ownership.

  ## Examples

      iex> change_food__track_with_user(food_track_id, user_id)
      %Ecto.Changeset{data: %Food_Track{}}

      iex> change_food__track_with_user(id_belonging_to_other_user, user_id)
      ** (Ecto.NoResultsError)
  """
  def change_food__track_with_user(id, user_id, attrs \\ %{}) do
    food__track = get_food__track!(id, user_id)
    change_food__track(food__track, attrs)
  end

  @doc """
  Counts the number of food tracks created/updated by a user today.

  ## Examples

      iex> count_todays_food_tracks(user_id)
      5

  """
  def count_todays_food_tracks(user_id) do
    # Return 0 if user_id is nil
    if is_nil(user_id) do
      0
    else
      today_start = Date.utc_today() |> DateTime.new!(~T[00:00:00], "Etc/UTC")
      today_end = Date.utc_today() |> DateTime.new!(~T[23:59:59.999999], "Etc/UTC")

      query =
        from(
          track in Food_Track,
          where:
            track.user_id == ^user_id and
              track.inserted_at >= ^today_start and
              track.inserted_at <= ^today_end
        )

      Repo.aggregate(query, :count, :id)
    end
  end

  @doc """
  Determines the user's daily food tracking limit based on their account status.
  Guest users (unconfirmed) can add 4 items per day.
  Confirmed users can add 16 items per day.

  ## Examples

      iex> get_daily_food_track_limit(user)
      16

  """
  def get_daily_food_track_limit(user) do
    cond do
      # Default guest limit
      is_nil(user) -> 4
      # Unconfirmed user limit
      is_nil(user.confirmed_at) -> 4
      # Confirmed user limit
      true -> 16
    end
  end

  @doc """
  Checks if a user has reached their daily limit for adding food tracks.

  ## Examples

      iex> can_add_food_track?(user)
      true

  """
  def can_add_food_track?(user) do
    user_id = if user, do: user.id, else: nil
    count = count_todays_food_tracks(user_id)
    limit = get_daily_food_track_limit(user)

    count < limit
  end
end
