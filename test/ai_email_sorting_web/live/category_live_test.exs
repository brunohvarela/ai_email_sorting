defmodule AiEmailSortingWeb.CategoryLiveTest do
  use AiEmailSortingWeb.ConnCase

  import Phoenix.LiveViewTest
  import AiEmailSorting.AccountsFixtures
  import AiEmailSorting.CategoriesFixtures

  @create_attrs %{name: "Product feedback", description: "Notes from NPS and concierge calls"}
  @update_attrs %{name: "Key clients", description: "VIP accounts who need a response within an hour"}
  @invalid_attrs %{name: "", description: ""}

  defp log_in(conn, user) do
    conn
    |> init_test_session(%{})
    |> put_session(:user_id, user.id)
  end

  describe "Index" do
    test "redirects unauthenticated visitors to the landing page", %{conn: conn} do
      assert {:error, {:redirect, %{to: ~p"/"}}} = live(conn, ~p"/categories")
    end

    test "lists only the signed-in user's categories", %{conn: conn} do
      user = user_fixture()
      other_user = user_fixture()

      my_category = category_fixture(user: user, name: "Priority clients")
      _other_category = category_fixture(user: other_user, name: "Finance")

      conn = log_in(conn, user)

      {:ok, _view, html} = live(conn, ~p"/categories")

      assert html =~ "Priority clients"
      refute html =~ "Finance"
      assert html =~ "1 active segment"
    end

    test "creates a new category from the inline composer", %{conn: conn} do
      user = user_fixture()
      conn = log_in(conn, user)

      {:ok, view, _html} = live(conn, ~p"/categories")

      view
      |> element("button[phx-click=\"new-category\"]", "New category")
      |> render_click()

      assert view |> element("#category-editor h2") |> render() =~ "Create a category"

      assert view
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      view
      |> form("#category-form", category: @create_attrs)
      |> render_submit()

      html = render(view)
      assert html =~ "Category created successfully"
      assert html =~ @create_attrs.name
      assert html =~ "2 active segments"
    end

    test "edits an existing category", %{conn: conn} do
      user = user_fixture()
      category = category_fixture(user: user)
      conn = log_in(conn, user)

      {:ok, view, _html} = live(conn, ~p"/categories")

      view
      |> element("button[phx-click=\"edit-category\"][phx-value-id=\"#{category.id}\"]", "Edit")
      |> render_click()

      assert render(view) =~ "Edit category"

      view
      |> form("#category-form", category: @update_attrs)
      |> render_submit()

      html = render(view)
      assert html =~ "Category updated successfully"
      assert html =~ @update_attrs.name
      assert html =~ @update_attrs.description
    end

    test "deletes a category from the list", %{conn: conn} do
      user = user_fixture()
      category = category_fixture(user: user)
      conn = log_in(conn, user)

      {:ok, view, _html} = live(conn, ~p"/categories")

      view
      |> element("button[phx-click=\"delete-category\"][phx-value-id=\"#{category.id}\"]", "Delete")
      |> render_click()

      refute render(view) =~ category.name
      assert render(view) =~ "Category deleted successfully"
    end
  end
end
