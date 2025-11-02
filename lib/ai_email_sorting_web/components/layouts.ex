defmodule AiEmailSortingWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use AiEmailSortingWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_user, :map,
    default: nil,
    doc: "the currently authenticated user, if any"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="px-4 py-6 sm:px-8">
      <div class="mx-auto flex max-w-6xl items-center justify-between gap-4">
        <a href="/" class="group inline-flex items-center gap-3">
          <img src={~p"/images/logo.svg"} width="40" height="40" alt="AiEmailSorting logo" class="rounded-xl shadow-sm transition-transform group-hover:-translate-y-0.5" />
          <div>
            <p class="text-sm font-semibold uppercase tracking-[0.2em] text-base-content/60">Ai Email Sorting</p>
            <p class="text-xs font-medium text-base-content/40">
              Powered by Phoenix v{Application.spec(:phoenix, :vsn)}
            </p>
          </div>
        </a>

        <nav class="flex items-center gap-3">
          <a
            href="https://phoenixframework.org/"
            class="hidden text-sm font-medium text-base-content/70 transition hover:text-base-content sm:inline-flex"
          >
            Product
          </a>
          <a
            href="https://github.com/phoenixframework/phoenix"
            class="hidden text-sm font-medium text-base-content/70 transition hover:text-base-content sm:inline-flex"
          >
            GitHub
          </a>
          <.theme_toggle />

          <div :if={@current_user} class="dropdown dropdown-end">
            <button class="btn btn-ghost h-11 min-h-11 gap-3 rounded-full px-3">
              <span class="avatar placeholder">
                <span class="size-9 rounded-full bg-primary/10 text-sm font-semibold text-primary">
                  {user_initials(@current_user)}
                </span>
              </span>
              <div class="hidden text-left sm:block">
                <p class="text-sm font-semibold leading-tight">
                  {@current_user.name || @current_user.email}
                </p>
                <p :if={@current_user.email} class="text-xs text-base-content/60">
                  {@current_user.email}
                </p>
              </div>
              <.icon name="hero-chevron-down" class="size-4 text-base-content/50" />
            </button>
            <ul class="menu dropdown-content z-[1] mt-2 w-60 rounded-box bg-base-200 p-3 shadow-2xl">
              <li class="mb-2 rounded-lg bg-base-100 p-3">
                <p class="text-sm font-medium">Signed in</p>
                <p class="text-xs text-base-content/60 truncate">{@current_user.email}</p>
              </li>
              <li>
                <.link
                  href={~p"/logout"}
                  method="delete"
                  data-confirm="Are you sure you want to sign out?"
                  class="btn btn-error btn-soft btn-sm justify-start"
                >
                  <.icon name="hero-arrow-left-on-rectangle" class="size-4" /> Sign out
                </.link>
              </li>
            </ul>
          </div>

          <.link
            :if={is_nil(@current_user)}
            href={~p"/auth/google"}
            class="btn btn-primary h-11 min-h-11 rounded-full px-5 text-sm font-semibold shadow-lg shadow-primary/30 transition hover:-translate-y-0.5"
          >
            <.icon name="hero-envelope" class="size-4" /> Sign in with Gmail
          </.link>
        </nav>
      </div>
    </header>

    <main class="px-4 pb-16 sm:px-8">
      <div class="mx-auto max-w-6xl">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  def user_initials(%{name: name}) when is_binary(name) and byte_size(name) > 0 do
    name
    |> String.split()
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
  end

  def user_initials(%{email: email}) when is_binary(email) do
    email
    |> String.first()
    |> String.upcase()
  end

  def user_initials(_), do: "?"

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
