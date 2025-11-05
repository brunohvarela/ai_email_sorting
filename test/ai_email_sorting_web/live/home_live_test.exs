defmodule AiEmailSortingWeb.HomeLiveTest do
  use AiEmailSortingWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias AiEmailSorting.AccountsFixtures
  alias AiEmailSorting.CategoriesFixtures

  describe "home page" do
    test "renders sections for guests", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Connect Gmail account"
      assert html =~ "You're browsing as a guest"
      assert html =~ "New category"
    end

    test "lists categories for the signed in user", %{conn: conn} do
      user = AccountsFixtures.user_fixture()
      _category = CategoriesFixtures.category_fixture(%{user: user, name: "VIP", description: "High value"})

      conn = conn |> Phoenix.ConnTest.init_test_session(%{}) |> Plug.Conn.put_session(:user_id, user.id)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "VIP"
      assert html =~ "High value"
    end

    test "allows creating a category", %{conn: conn} do
      user = AccountsFixtures.user_fixture()
      conn = conn |> Phoenix.ConnTest.init_test_session(%{}) |> Plug.Conn.put_session(:user_id, user.id)

      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> element("#add-category-button")
      |> render_click()

      params = %{name: "Operations", description: "Operational updates"}

      view
      |> form("#new-category-form", %{category: params})
      |> render_submit()

      html = render(view)

      assert html =~ "Category created successfully."
      assert html =~ "Operations"
      assert html =~ "Operational updates"
    end
  end
end
