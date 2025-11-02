defmodule AiEmailSortingWeb.CategoryLive.Index do
  use AiEmailSortingWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Categories")
     |> assign(:categories, [])}
  end
end
