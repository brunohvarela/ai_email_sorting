defmodule AiEmailSortingWeb.PageController do
  use AiEmailSortingWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
