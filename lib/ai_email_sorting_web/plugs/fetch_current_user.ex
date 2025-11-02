defmodule AiEmailSortingWeb.Plugs.FetchCurrentUser do
  @moduledoc """
  Loads the current user from session data into the connection assigns.
  """

  import Plug.Conn

  alias AiEmailSorting.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user =
      cond do
        conn.assigns[:current_user] ->
          conn.assigns[:current_user]

        user_id = get_session(conn, :user_id) ->
          Accounts.get_user(user_id)

        true ->
          nil
      end

    assign(conn, :current_user, current_user)
  end
end
