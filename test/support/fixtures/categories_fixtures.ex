defmodule AiEmailSorting.CategoriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AiEmailSorting.Categories` context.
  """

  import AiEmailSorting.AccountsFixtures

  alias AiEmailSorting.Categories

  @doc """
  Generate a category scoped to the given user.
  """
  def category_fixture(attrs \\ %{}) do
    user = Map.get_lazy(attrs, :user, fn -> user_fixture() end)

    attrs =
      attrs
      |> Map.drop([:user])
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })

    {:ok, category} = Categories.create_category_for_user(user, attrs)
    category
  end
end
