defmodule AiEmailSorting.EmailSummaries.EmailSummary do
  @moduledoc """
  Schema representing an email summary linked to a category.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias AiEmailSorting.Categories.Category

  schema "email_summaries" do
    field :from, :string
    field :subject, :string
    field :summary, :string

    belongs_to :category, Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(email_summary, attrs) do
    email_summary
    |> cast(attrs, [:from, :subject, :summary, :category_id])
    |> validate_required([:from, :subject, :summary, :category_id])
    |> assoc_constraint(:category)
  end
end
