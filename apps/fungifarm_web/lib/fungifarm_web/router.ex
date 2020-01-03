defmodule FungifarmWeb.Router do
  use FungifarmWeb, :router

  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FungifarmWeb do
    pipe_through :browser

    live "/", Live.Index
    # live "/", PageController, :index
    live "/graph/:topic", Live.Graph
  end

  # Other scopes may use custom stacks.
  # scope "/api", FungifarmWeb do
  #   pipe_through :api
  # end
end
