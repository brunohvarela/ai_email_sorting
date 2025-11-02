defmodule AiEmailSorting.Accounts.User do
  @moduledoc """
  Represents an authenticated user within the system.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :google_uid, :string
    field :email, :string
    field :name, :string
    field :given_name, :string
    field :family_name, :string
    field :avatar_url, :string
    field :locale, :string
    field :access_token, :string
    field :refresh_token, :string
    field :token_expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def google_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :google_uid,
      :email,
      :name,
      :given_name,
      :family_name,
      :avatar_url,
      :locale,
      :access_token,
      :refresh_token,
      :token_expires_at
    ])
    |> validate_required([:google_uid, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:google_uid)
    |> unique_constraint(:email)
  end
end
