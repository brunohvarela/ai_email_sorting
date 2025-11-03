defmodule AiEmailSorting.Categories do
  @moduledoc """
  The Categories context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset

  alias AiEmailSorting.Accounts.User
  alias AiEmailSorting.Categories.Category
  alias AiEmailSorting.Repo

  @doc """
  Returns all categories that belong to the given user ordered by insertion time.
  """
  @spec list_categories_for_user(User.t()) :: [Category.t()]
  def list_categories_for_user(%User{id: user_id}) do
    Category
    |> where([c], c.user_id == ^user_id)
    |> order_by([c], asc: c.inserted_at)
    |> Repo.all()
  end

  @doc """
  Fetches a category that belongs to the given user.

  Raises `Ecto.NoResultsError` if the category cannot be found for the user.
  """
  @spec get_category_for_user!(User.t(), integer() | binary()) :: Category.t()
  def get_category_for_user!(%User{id: user_id}, id) when is_integer(id) do
    Repo.get_by!(Category, id: id, user_id: user_id)
  end

  def get_category_for_user!(%User{} = user, id) when is_binary(id) do
    id
    |> String.to_integer()
    |> get_category_for_user!(user)
  rescue
    ArgumentError -> raise Ecto.NoResultsError, queryable: Category
  end

  @doc """
  Creates a category owned by the given user.
  """
  @spec create_category_for_user(User.t(), map()) ::
          {:ok, Category.t()} | {:error, Changeset.t()}
  def create_category_for_user(%User{} = user, attrs) when is_map(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> associate_user(user)
    |> Repo.insert()
  end

  @doc """
  Updates a category that belongs to the given user.
  """
  @spec update_category_for_user(User.t(), Category.t(), map()) ::
          {:ok, Category.t()} | {:error, Changeset.t()}
  def update_category_for_user(%User{} = user, %Category{} = category, attrs) when is_map(attrs) do
    category = get_category_for_user!(user, category.id)

    category
    |> Category.changeset(attrs)
    |> associate_user(user)
    |> Repo.update()
  end

  @doc """
  Deletes a category that belongs to the given user.
  """
  @spec delete_category_for_user(User.t(), Category.t()) ::
          {:ok, Category.t()} | {:error, Changeset.t()}
  def delete_category_for_user(%User{} = user, %Category{} = category) do
    category = get_category_for_user!(user, category.id)

    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.
  """
  @spec change_category(Category.t(), map()) :: Changeset.t()
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  defp associate_user(%Changeset{} = changeset, %User{id: user_id}) do
    changeset
    |> Changeset.put_change(:user_id, user_id)
    |> Changeset.validate_required([:user_id])
    |> Changeset.assoc_constraint(:user)
  end
end
