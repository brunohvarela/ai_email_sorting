defmodule AiEmailSorting.EmailSummaries do
  @moduledoc """
  The EmailSummaries context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Changeset

  alias AiEmailSorting.EmailSummaries.EmailSummary
  alias AiEmailSorting.Repo

  @doc """
  Returns the list of email summaries.
  """
  @spec list_email_summaries() :: [EmailSummary.t()]
  def list_email_summaries do
    Repo.all(EmailSummary)
  end

  @doc """
  Gets a single email summary.

  Raises `Ecto.NoResultsError` if the EmailSummary does not exist.
  """
  @spec get_email_summary!(integer()) :: EmailSummary.t()
  def get_email_summary!(id), do: Repo.get!(EmailSummary, id)

  @doc """
  Creates an email summary.
  """
  @spec create_email_summary(map()) :: {:ok, EmailSummary.t()} | {:error, Changeset.t()}
  def create_email_summary(attrs \\ %{}) do
    %EmailSummary{}
    |> EmailSummary.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an email summary.
  """
  @spec update_email_summary(EmailSummary.t(), map()) ::
          {:ok, EmailSummary.t()} | {:error, Changeset.t()}
  def update_email_summary(%EmailSummary{} = email_summary, attrs) do
    email_summary
    |> EmailSummary.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an email summary.
  """
  @spec delete_email_summary(EmailSummary.t()) :: {:ok, EmailSummary.t()} | {:error, Changeset.t()}
  def delete_email_summary(%EmailSummary{} = email_summary) do
    Repo.delete(email_summary)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking email summary changes.
  """
  @spec change_email_summary(EmailSummary.t(), map()) :: Changeset.t()
  def change_email_summary(%EmailSummary{} = email_summary, attrs \\ %{}) do
    EmailSummary.changeset(email_summary, attrs)
  end
end
