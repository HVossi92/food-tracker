defmodule FoodTracker.Food_Tracking do
  @moduledoc """
  The Food_Tracking context.
  """

  import Ecto.Query, warn: false
  alias FoodTracker.Repo

  alias FoodTracker.Food_Tracking.Food_Track

  @doc """
  Returns the list of food_tracks.

  ## Examples

      iex> list_food_tracks()
      [%Food_Track{}, ...]

  """
  def list_food_tracks(user_id) do
    query = from(track in Food_Track, where: track.user_id == ^user_id)

    Repo.all(query)
    |> Enum.map(fn track ->
      %{track | date: FoodTracker.Utils.year_month_day_to_day_month_year(track.date)}
    end)
  end

  def list_food_tracks_on(date, user_id) do
    if FoodTracker.Utils.is_valid_date_string?(date) do
      query = from(track in Food_Track, where: track.date == ^date and track.user_id == ^user_id)

      Repo.all(query)
      |> Enum.map(fn track ->
        %{track | date: FoodTracker.Utils.year_month_day_to_day_month_year(track.date)}
      end)
    else
      {:error, "Invalid date format"}
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
  def get_food__track!(id), do: Repo.get!(Food_Track, id)

  @doc """
  Creates a food__track.

  ## Examples

      iex> create_food__track(%{field: value})
      {:ok, %Food_Track{}}

      iex> create_food__track(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_food__track(attrs \\ %{}) do
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
  def update_food__track(%Food_Track{} = food__track, attrs) do
    food__track
    |> Food_Track.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a food__track.

  ## Examples

      iex> delete_food__track(food__track)
      {:ok, %Food_Track{}}

      iex> delete_food__track(food__track)
      {:error, %Ecto.Changeset{}}

  """
  def delete_food__track(%Food_Track{} = food__track) do
    Repo.delete(food__track)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking food__track changes.

  ## Examples

      iex> change_food__track(food__track)
      %Ecto.Changeset{data: %Food_Track{}}

  """
  def change_food__track(food__track, attrs \\ %{})

  # Handle nil case
  def change_food__track(nil, attrs) do
    change_food__track(%Food_Track{}, attrs)
  end

  def change_food__track(%Food_Track{} = food__track, attrs) do
    Food_Track.changeset(food__track, attrs)
  end
end
