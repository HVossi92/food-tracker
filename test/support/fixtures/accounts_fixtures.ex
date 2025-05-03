defmodule FoodTracker.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FoodTracker.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        password: valid_user_password()
      })
      |> FoodTracker.Accounts.register_user()

    user
  end

  @doc """
  Generate an anonymous user.
  """
  def anonymous_user_fixture(attrs \\ %{}) do
    anonymous_uuid = Ecto.UUID.generate()

    {:ok, user} =
      attrs
      |> Enum.into(%{
        anonymous_uuid: anonymous_uuid,
        is_anonymous: true,
        last_active_at: DateTime.utc_now() |> DateTime.truncate(:second)
      })
      |> FoodTracker.Accounts.create_anonymous_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
