defmodule AiEmailSorting.Accounts do
  @moduledoc """
  The Accounts context handles user persistence and authentication helpers.
  """

  import Ecto.Query, warn: false

  alias AiEmailSorting.Accounts.User
  alias AiEmailSorting.Repo

  @doc """
  Gets a user by their database identifier.
  """
  def get_user(id) when is_integer(id) do
    Repo.get(User, id)
  end

  def get_user(id) when is_binary(id) do
    case Integer.parse(id) do
      {int_id, ""} -> Repo.get(User, int_id)
      _ -> nil
    end
  end

  @doc """
  Retrieves a user by their Google UID.
  """
  def get_user_by_google_uid(google_uid) when is_binary(google_uid) do
    Repo.get_by(User, google_uid: google_uid)
  end

  @doc """
  Inserts or updates a user record based on the data returned by Google OAuth.
  """
  def upsert_google_user(attrs) when is_map(attrs) do
    google_uid = Map.fetch!(attrs, :google_uid)

    case get_user_by_google_uid(google_uid) do
      nil ->
        %User{}
        |> User.google_changeset(attrs)
        |> Repo.insert()

      %User{} = user ->
        user
        |> User.google_changeset(attrs)
        |> Repo.update()
    end
  end
end
