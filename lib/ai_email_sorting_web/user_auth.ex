defmodule AiEmailSortingWeb.UserAuth do
  @moduledoc """
  LiveView and controller helpers for user authentication.
  """

  import Phoenix.Component, only: [assign_new: 3]
  import Phoenix.LiveView

  alias AiEmailSorting.Accounts

  def on_mount(:mount_current_user, _params, session, socket) do
    current_user = Map.get(session, "user_id") |> maybe_get_user()
    {:cont, assign_new(socket, :current_user, fn -> current_user end)}
  end

  def on_mount(:ensure_authenticated, params, session, socket) do
    current_user = Map.get(session, "user_id") |> maybe_get_user()

    socket = assign_new(socket, :current_user, fn -> current_user end)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: after_login_path(params))}
    end
  end

  defp after_login_path(%{"redirect_to" => redirect}), do: redirect
  defp after_login_path(_), do: "/"

  defp maybe_get_user(nil), do: nil
  defp maybe_get_user(user_id), do: Accounts.get_user(user_id)
end
