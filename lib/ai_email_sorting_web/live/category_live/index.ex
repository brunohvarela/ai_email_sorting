defmodule AiEmailSortingWeb.CategoryLive.Index do
  use AiEmailSortingWeb, :live_view

  alias AiEmailSorting.Categories
  alias AiEmailSorting.Categories.Category

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Categories")
      |> assign(:form_mode, :hidden)
      |> assign(:form_category, %Category{})
      |> assign(:editing_category, nil)
      |> assign_form(Categories.change_category(%Category{}))
      |> refresh_categories()

    {:ok, socket}
  end

  @impl true
  def handle_event("new-category", _params, socket) do
    {:noreply,
     socket
     |> assign(:form_mode, :create)
     |> assign(:form_category, %Category{})
     |> assign(:editing_category, nil)
     |> assign_form(Categories.change_category(%Category{}))}
  end

  @impl true
  def handle_event("edit-category", %{"id" => id}, socket) do
    category = Categories.get_category_for_user!(socket.assigns.current_user, id)

    {:noreply,
     socket
     |> assign(:form_mode, :edit)
     |> assign(:form_category, category)
     |> assign(:editing_category, category)
     |> assign_form(Categories.change_category(category))}
  end

  @impl true
  def handle_event("cancel-form", _params, socket) do
    {:noreply, reset_form(socket)}
  end

  @impl true
  def handle_event("validate-category", %{"category" => params}, socket) do
    changeset =
      socket.assigns.form_category
      |> Categories.change_category(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save-category", %{"category" => params}, socket) do
    case socket.assigns.form_mode do
      :create -> create_category(socket, params)
      :edit -> update_category(socket, params)
      _other -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("delete-category", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    category = Categories.get_category_for_user!(user, id)

    case Categories.delete_category_for_user(user, category) do
      {:ok, deleted_category} ->
        socket =
          socket
          |> maybe_reset_form_after_delete(deleted_category)
          |> put_flash(:info, "Category deleted successfully.")
          |> refresh_categories()

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Unable to delete that category right now.")}
    end
  end

  defp create_category(socket, params) do
    user = socket.assigns.current_user

    case Categories.create_category_for_user(user, params) do
      {:ok, _category} ->
        socket =
          socket
          |> put_flash(:info, "Category created successfully.")
          |> reset_form()
          |> refresh_categories()

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp update_category(socket, params) do
    user = socket.assigns.current_user
    category = socket.assigns.form_category

    case Categories.update_category_for_user(user, category, params) do
      {:ok, _category} ->
        socket =
          socket
          |> put_flash(:info, "Category updated successfully.")
          |> reset_form()
          |> refresh_categories()

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp refresh_categories(socket) do
    categories = Categories.list_categories_for_user(socket.assigns.current_user)

    socket
    |> assign(:category_count, length(categories))
    |> assign(:categories_empty?, categories == [])
    |> stream(:categories, categories, reset: true)
  end

  defp reset_form(socket) do
    socket
    |> assign(:form_mode, :hidden)
    |> assign(:form_category, %Category{})
    |> assign(:editing_category, nil)
    |> assign_form(Categories.change_category(%Category{}))
  end

  defp maybe_reset_form_after_delete(socket, %Category{id: id}) do
    case socket.assigns.editing_category do
      %Category{id: ^id} -> reset_form(socket)
      _ -> socket
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
