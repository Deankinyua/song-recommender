defmodule SongRecommenderWeb.LiveHelpers do
  @moduledoc """
  On mount hooks and other helper functions called for LiveViews
  """

  import Phoenix.Component, only: [assign: 3]
  import Phoenix.LiveView, only: [get_connect_params: 1]

  @type socket :: Phoenix.LiveView.Socket.t()

  @spec on_mount(atom(), map(), map(), socket()) :: {:cont, socket()}
  def on_mount(:maybe_capture_user_preferences, _params, _session, socket) do
    capture_user_preferences =
      case get_connect_params(socket) do
        %{"capture_user_preferences" => "true"} -> true
        _other -> false
      end

    {:cont, assign(socket, :capture_user_preferences?, capture_user_preferences)}
  end
end
