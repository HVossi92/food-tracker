defmodule FoodTracker.Utils do
  def string_to_date(date_string) do
    case String.contains?(date_string, ".") do
      true ->
        # Handle DD.MM.YYYY format
        [day, month, year] = String.split(date_string, ".")

        {:ok, date} =
          Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day))

        date

      false ->
        # Handle YYYY-MM-DD format
        [year, month, day] = String.split(date_string, "-")

        {:ok, date} =
          Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day))

        date
    end
  end

  def date_to_dmy_string(date) do
    Calendar.strftime(date, "%d.%m.%Y")
  end

  def date_to_ymd_string(date) do
    Calendar.strftime(date, "%Y-%m-%d")
  end

  def year_month_day_to_day_month_year(date_string) do
    [year, month, day] = String.split(date_string, "-")
    "#{day}.#{month}.#{year}"
  end

  def is_valid_date_string?(date_string) do
    try do
      string_to_date(date_string)
      true
    rescue
      _ -> false
    end
  end
end
