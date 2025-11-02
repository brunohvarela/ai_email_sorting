defmodule AiEmailSortingWeb.AuthController do
  use AiEmailSortingWeb, :controller

  alias AiEmailSorting.Accounts
  alias AiEmailSorting.GoogleOAuth

  plug :ensure_google_config when action in [:request, :callback]

  def request(conn, params) do
    redirect_to = Map.get(params, "redirect_to")
    state = random_state()

    conn
    |> put_session(:oauth_state, state)
    |> maybe_put_redirect(redirect_to)
    |> redirect(external: GoogleOAuth.authorization_url(state, callback_url(conn)))
  end

  def callback(conn, %{"code" => code, "state" => returned_state}) do
    with {:ok, stored_state} <- fetch_state(conn),
         :ok <- validate_state(stored_state, returned_state),
         {:ok, token_payload} <- exchange_code(code, callback_url(conn)),
         {:ok, user_info} <- fetch_userinfo(token_payload),
         {:ok, user} <- persist_user(token_payload, user_info) do
      redirect_path = get_session(conn, :redirect_after_login) || "/"

      conn
      |> configure_session(renew: true)
      |> delete_session(:oauth_state)
       |> delete_session(:redirect_after_login)
      |> put_session(:user_id, user.id)
      |> put_flash(:info, welcome_message(user))
      |> redirect(to: redirect_path)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, changeset_message(changeset))
        |> redirect(to: "/")

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: "/")
    end
  end

  def callback(conn, %{"error" => error}) do
    conn
    |> put_flash(:error, oauth_error_message(error))
    |> redirect(to: "/")
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Missing authorization response from Google.")
    |> redirect(to: "/")
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Signed out successfully.")
    |> redirect(to: "/")
  end

  defp ensure_google_config(conn, _opts) do
    GoogleOAuth.ensure_config!()
    conn
  rescue
    RuntimeError ->
      raise "Google OAuth credentials are not configured"
  end

  defp callback_url(conn) do
    url(~p"/auth/google/callback")
  end

  defp fetch_state(conn) do
    case get_session(conn, :oauth_state) do
      nil -> {:error, "The login session has expired. Please try again."}
      state -> {:ok, state}
    end
  end

  defp validate_state(expected, returned) do
    if Plug.Crypto.secure_compare(expected, returned) do
      :ok
    else
      {:error, "State parameter mismatch. Please try logging in again."}
    end
  end

  defp exchange_code(code, redirect_uri) do
    {:ok, GoogleOAuth.exchange_code!(code, redirect_uri)}
  rescue
    e in [Req.Error, RuntimeError] ->
      {:error, "Failed to exchange authorization code: #{Exception.message(e)}"}
  end

  defp fetch_userinfo(%{"access_token" => access_token} = payload) when is_binary(access_token) do
    {:ok, GoogleOAuth.fetch_userinfo!(access_token)}
  rescue
    e in [Req.Error, RuntimeError] ->
      {:error, "Failed to fetch user information: #{Exception.message(e)}"}
  end

  defp fetch_userinfo(_), do: {:error, "Access token missing from Google response."}

  defp persist_user(token_payload, user_info) do
    attrs = build_user_attrs(token_payload, user_info)

    cond do
      is_nil(attrs.google_uid) ->
        {:error, "Google did not return a user identifier."}

      is_nil(attrs.email) ->
        {:error, "Google did not share an email address for this account."}

      true ->
        Accounts.upsert_google_user(attrs)
    end
  end

  defp build_user_attrs(token_payload, user_info) do
    %{
      google_uid: Map.get(user_info, "sub"),
      email: Map.get(user_info, "email"),
      name: Map.get(user_info, "name"),
      given_name: Map.get(user_info, "given_name"),
      family_name: Map.get(user_info, "family_name"),
      avatar_url: Map.get(user_info, "picture"),
      locale: Map.get(user_info, "locale"),
      access_token: Map.get(token_payload, "access_token"),
      refresh_token: Map.get(token_payload, "refresh_token"),
      token_expires_at: token_expiry(token_payload)
    }
  end

  defp token_expiry(%{"expires_in" => expires_in}) when is_integer(expires_in) do
    DateTime.utc_now() |> DateTime.add(expires_in, :second)
  end

  defp token_expiry(%{"expires_in" => expires_in}) when is_binary(expires_in) do
    case Integer.parse(expires_in) do
      {int, _} -> DateTime.utc_now() |> DateTime.add(int, :second)
      :error -> nil
    end
  end

  defp token_expiry(_), do: nil

  defp welcome_message(%{name: name}) when is_binary(name) and byte_size(name) > 0 do
    "Welcome back, #{name}!"
  end

  defp welcome_message(%{email: email}) when is_binary(email) do
    "Welcome back, #{email}!"
  end

  defp welcome_message(_), do: "Signed in successfully."

  defp oauth_error_message(error) do
    case error do
      "access_denied" -> "You denied the request. Please authorize access to continue."
      other -> "Google returned an error: #{other}."
    end
  end

  defp random_state do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)
  end

  defp maybe_put_redirect(conn, nil), do: conn

  defp maybe_put_redirect(conn, redirect_to) do
    put_session(conn, :redirect_after_login, redirect_to)
  end

  defp changeset_message(changeset) do
    errors =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
        Gettext.dgettext(AiEmailSortingWeb.Gettext, "errors", msg, opts)
      end)

    errors
    |> Enum.map(fn {field, msgs} ->
      human_field = Phoenix.Naming.humanize(field)
      Enum.map(msgs, &"#{human_field} #{&1}")
    end)
    |> List.flatten()
    |> Enum.join(", ")
    |> case do
      "" -> "We couldn't save your Google profile details."
      message -> message
    end
  end
end
