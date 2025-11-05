defmodule AiEmailSortingWeb.HomeLive do
  use AiEmailSortingWeb, :live_view

  alias AiEmailSorting.Accounts.User
  alias AiEmailSorting.Categories
  alias AiEmailSorting.Categories.Category

  @impl true
  def mount(_params, _session, socket) do
    changeset = Categories.change_category(%Category{})

    socket =
      socket
      |> assign(:page_title, "Home")
      |> assign(:form_open?, false)
      |> assign_form(changeset)
      |> assign_categories()

    {:ok, socket}
  end

  @impl true
  def handle_event("open-category-form", _params, socket) do
    {:noreply, assign(socket, :form_open?, true)}
  end

  @impl true
  def handle_event("cancel-category-form", _params, socket) do
    {:noreply, reset_form(socket)}
  end

  @impl true
  def handle_event("validate-category", %{"category" => params}, socket) do
    changeset =
      %Category{}
      |> Categories.change_category(params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:form_open?, true)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("save-category", %{"category" => params}, socket) do
    case socket.assigns.current_user do
      %User{} = user -> create_category(socket, user, params)
      _ -> {:noreply, require_authentication(socket)}
    end
  end

  defp create_category(socket, user, params) do
    case Categories.create_category_for_user(user, params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Category created successfully.")
         |> reset_form()
         |> assign_categories()}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:form_open?, true)
         |> assign_form(Map.put(changeset, :action, :validate))}
    end
  end

  defp require_authentication(socket) do
    socket
    |> put_flash(:error, "Sign in to create categories.")
    |> assign(:form_open?, true)
    |> assign_form(%Category{} |> Categories.change_category() |> Map.put(:action, :validate))
  end

  defp reset_form(socket) do
    socket
    |> assign(:form_open?, false)
    |> assign_form(Categories.change_category(%Category{}))
  end

  defp assign_categories(socket) do
    categories =
      case socket.assigns[:current_user] do
        %User{} = user -> Categories.list_categories_for_user(user)
        _ -> []
      end

    socket
    |> assign(:categories, categories)
    |> assign(:category_count, length(categories))
    |> assign(:categories_empty?, Enum.empty?(categories))
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    socket
    |> assign(:category_changeset, changeset)
    |> assign(:form, to_form(changeset))
  end
end
