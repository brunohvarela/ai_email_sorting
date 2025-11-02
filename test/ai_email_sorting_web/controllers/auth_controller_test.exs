defmodule AiEmailSortingWeb.AuthControllerTest do
  use AiEmailSortingWeb.ConnCase, async: true

  alias AiEmailSorting.Accounts.User
  alias AiEmailSorting.Repo

  import Phoenix.ConnTest

  defmodule GoogleOAuthTestClient do
    def post!(url, opts), do: respond({:post, url}, opts)
    def get!(url, opts), do: respond({:get, url}, opts)

    defp respond(key, opts) do
      responses = Process.get(:google_oauth_responses) || %{}

      case Map.pop(responses, key) do
        {nil, _} -> raise "No stubbed response for #{inspect(key)}"
        {response_fun, remaining} ->
          Process.put(:google_oauth_responses, remaining)
          response_fun.(opts)
      end
    end
  end

  setup %{conn: conn} do
    original_config = Application.get_env(:ai_email_sorting, AiEmailSorting.GoogleOAuth)

    config = Keyword.put(original_config, :http_client, GoogleOAuthTestClient)
    Application.put_env(:ai_email_sorting, AiEmailSorting.GoogleOAuth, config)

    on_exit(fn ->
      Application.put_env(:ai_email_sorting, AiEmailSorting.GoogleOAuth, original_config)
    end)

    {:ok, conn: Phoenix.ConnTest.init_test_session(conn, %{})}
  end

  describe "GET /auth/google" do
    test "redirects to Google with a signed state", %{conn: conn} do
      conn = get(conn, ~p"/auth/google")

      assert redirected_to(conn) =~ "https://accounts.google.com/o/oauth2/v2/auth"

      %{"state" => state} = URI.decode_query(URI.parse(redirected_to(conn)).query)
      assert state == get_session(conn, :oauth_state)
    end
  end

  describe "GET /auth/google/callback" do
    test "fails when the state does not match", %{conn: conn} do
      conn =
        conn
        |> put_session(:oauth_state, "expected")
        |> get(~p"/auth/google/callback", %{"state" => "invalid", "code" => "ignored"})

      assert get_flash(conn, :error) =~ "State parameter mismatch"
      assert redirected_to(conn) == ~p"/"
    end

    test "creates or updates the user and signs them in", %{conn: conn} do
      state = "state123"

      token_response = %{
        access_token: "access-token",
        refresh_token: "refresh-token",
        expires_in: 3_600,
        token_type: "Bearer"
      }

      userinfo_response = %{
        sub: "google-uid",
        email: "sequoia@gmail.com",
        name: "Sequoia AI",
        picture: "https://example.com/avatar.png"
      }

      Process.put(:google_oauth_responses, %{
        {:post, "https://oauth2.googleapis.com/token"} => fn opts ->
          assert opts[:form]["code"] == "auth-code"
          %{body: token_response}
        end,
        {:get, "https://www.googleapis.com/oauth2/v3/userinfo"} => fn opts ->
          assert opts[:headers] == [{"authorization", "Bearer access-token"}]
          %{body: userinfo_response}
        end
      })

      conn =
        conn
        |> put_session(:oauth_state, state)
        |> get(~p"/auth/google/callback", %{"state" => state, "code" => "auth-code"})

      assert redirected_to(conn) == ~p"/"
      assert get_flash(conn, :info) =~ "Welcome back"

      user = Repo.get_by!(User, google_uid: "google-uid")
      assert get_session(conn, :user_id) == user.id
      assert user.email == "sequoia@gmail.com"
      assert user.access_token == "access-token"
      assert user.refresh_token == "refresh-token"
      assert user.token_expires_at
    end
  end
end
