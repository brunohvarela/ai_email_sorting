defmodule AiEmailSorting.GoogleOAuth do
  @moduledoc """
  Encapsulates Google OAuth endpoints and requests.
  """

  @default_scope "openid email profile"

  def config do
    Application.get_env(:ai_email_sorting, __MODULE__, [])
  end

  def authorization_url(state, redirect_uri) do
    endpoint = Keyword.get(config(), :authorization_endpoint, "https://accounts.google.com/o/oauth2/v2/auth")
    client_id = fetch_config!(:client_id)
    scope = Keyword.get(config(), :scope, @default_scope)

    query =
      %{
        "client_id" => client_id,
        "redirect_uri" => redirect_uri,
        "response_type" => "code",
        "scope" => scope,
        "access_type" => "offline",
        "include_granted_scopes" => "true",
        "prompt" => "consent",
        "state" => state
      }
      |> URI.encode_query()

    endpoint <> "?" <> query
  end

  def exchange_code!(code, redirect_uri) do
    token_endpoint = Keyword.get(config(), :token_endpoint, "https://oauth2.googleapis.com/token")
    client_id = fetch_config!(:client_id)
    client_secret = fetch_config!(:client_secret)

    form = %{
      "code" => code,
      "client_id" => client_id,
      "client_secret" => client_secret,
      "redirect_uri" => redirect_uri,
      "grant_type" => "authorization_code"
    }

    token_endpoint
    |> request(:post, form: form)
    |> Map.fetch!(:body)
  end

  def refresh_token!(refresh_token) do
    token_endpoint = Keyword.get(config(), :token_endpoint, "https://oauth2.googleapis.com/token")
    client_id = fetch_config!(:client_id)
    client_secret = fetch_config!(:client_secret)

    form = %{
      "refresh_token" => refresh_token,
      "client_id" => client_id,
      "client_secret" => client_secret,
      "grant_type" => "refresh_token"
    }

    token_endpoint
    |> request(:post, form: form)
    |> Map.fetch!(:body)
  end

  def ensure_config! do
    Enum.each([:client_id, :client_secret], fn key -> fetch_config!(key) end)
    :ok
  end

  def fetch_userinfo!(access_token) do
    userinfo_endpoint = Keyword.get(config(), :userinfo_endpoint, "https://www.googleapis.com/oauth2/v3/userinfo")

    request(userinfo_endpoint, :get,
      headers: [
        {"authorization", "Bearer #{access_token}"}
      ]
    )
    |> Map.fetch!(:body)
  end

  defp request(url, method, opts) do
    client = Keyword.get(config(), :http_client, Req)
    apply(client, method_to_function_name(method), [url, opts])
  end

  defp method_to_function_name(:get), do: :get!
  defp method_to_function_name(:post), do: :post!
  defp method_to_function_name(other), do: raise "Unsupported method #{inspect(other)}"

  defp fetch_config!(key) do
    case Keyword.fetch(config(), key) do
      {:ok, value} when value not in [nil, ""] -> value
      _ ->
        raise "Missing Google OAuth configuration for #{inspect(key)}"
    end
  end
end
