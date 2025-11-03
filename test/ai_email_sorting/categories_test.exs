defmodule AiEmailSorting.CategoriesTest do
  use AiEmailSorting.DataCase

  alias AiEmailSorting.Categories

  describe "categories" do
    alias AiEmailSorting.Categories.Category

    import AiEmailSorting.AccountsFixtures
    import AiEmailSorting.CategoriesFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_categories_for_user/1 returns categories for the user" do
      owner = user_fixture()
      other_user = user_fixture()

      category = category_fixture(user: owner, name: "Owner category")
      _other_category = category_fixture(user: other_user, name: "Other category")

      assert [%Category{name: "Owner category"}] = Categories.list_categories_for_user(owner)
    end

    test "get_category_for_user!/2 returns the category for the owner" do
      owner = user_fixture()
      category = category_fixture(user: owner)

      assert %Category{id: ^category.id} = Categories.get_category_for_user!(owner, category.id)
    end

    test "get_category_for_user!/2 raises if the category is not owned" do
      owner = user_fixture()
      stranger = user_fixture()
      category = category_fixture(user: owner)

      assert_raise Ecto.NoResultsError, fn -> Categories.get_category_for_user!(stranger, category.id) end
    end

    test "create_category_for_user/2 with valid data creates a category" do
      user = user_fixture()
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %Category{} = category} = Categories.create_category_for_user(user, valid_attrs)
      assert category.name == "some name"
      assert category.description == "some description"
      assert category.user_id == user.id
    end

    test "create_category_for_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Categories.create_category_for_user(user, @invalid_attrs)
    end

    test "update_category_for_user/3 with valid data updates the category" do
      user = user_fixture()
      category = category_fixture(user: user)
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Category{} = updated} = Categories.update_category_for_user(user, category, update_attrs)
      assert updated.name == "some updated name"
      assert updated.description == "some updated description"
      assert updated.user_id == user.id
    end

    test "update_category_for_user/3 with invalid data returns error changeset" do
      user = user_fixture()
      category = category_fixture(user: user)
      assert {:error, %Ecto.Changeset{}} = Categories.update_category_for_user(user, category, @invalid_attrs)
      assert %Category{id: ^category.id} = Categories.get_category_for_user!(user, category.id)
    end

    test "delete_category_for_user/2 deletes the category" do
      user = user_fixture()
      category = category_fixture(user: user)

      assert {:ok, %Category{}} = Categories.delete_category_for_user(user, category)
      assert_raise Ecto.NoResultsError, fn -> Categories.get_category_for_user!(user, category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Categories.change_category(category)
    end
  end
end
