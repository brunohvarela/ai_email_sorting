defmodule AiEmailSorting.EmailSummariesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AiEmailSorting.EmailSummaries` context.
  """

  import AiEmailSorting.CategoriesFixtures

  alias AiEmailSorting.EmailSummaries

  @doc """
  Generate an email summary associated to a category.
  """
  def email_summary_fixture(attrs \\ %{}) do
    category = Map.get_lazy(attrs, :category, fn -> category_fixture() end)

    attrs =
      attrs
      |> Map.drop([:category, :category_id])
      |> Enum.into(%{
        from: "sender@example.com",
        subject: "some subject",
        summary: "some summary"
      })

    {:ok, email_summary} =
      attrs
      |> Map.put(:category_id, category.id)
      |> EmailSummaries.create_email_summary()

    email_summary
  end
end
