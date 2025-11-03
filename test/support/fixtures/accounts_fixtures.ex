defmodule AiEmailSorting.AccountsFixtures do
  @moduledoc """
  Test helpers for creating accounts-related entities.
  """

  alias AiEmailSorting.Accounts

  def unique_google_uid, do: "uid-#{System.unique_integer([:positive])}"

  defp unique_email do
    "user#{System.unique_integer([:positive])}@example.com"
  end

  @doc """
  Generate a user persisted via the Accounts context.
  """
  def user_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        google_uid: unique_google_uid(),
        email: unique_email(),
        name: "Test User",
        given_name: "Test",
        family_name: "User"
      })

    {:ok, user} = Accounts.upsert_google_user(attrs)
    user
  end
end
