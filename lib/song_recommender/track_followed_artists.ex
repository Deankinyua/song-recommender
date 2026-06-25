defmodule SongRecommender.TrackFollowedArtists do
  @moduledoc """
  Starts and manages an :ets table responsible for caching all
  artists that particular users are following.
  """

  use GenServer

  @type artist_name :: String.t()
  @type artists :: MapSet.t()
  @type username :: String.t()

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl GenServer
  def init(state) do
    :ets.new(:followed_artists, [:set, :public, :named_table])
    {:ok, state}
  end

  @spec cache_artists(artists(), username()) :: true
  def cache_artists(followed_artists, username),
    do: :ets.insert(:followed_artists, {username, followed_artists})

  @spec clear_artists_cache(username()) :: true
  def clear_artists_cache(username),
    do: :ets.delete(:followed_artists, username)

  @spec following?(username(), artist_name()) :: boolean()
  def following?(username, artist_name) do
    [{_username, followed_artists}] = :ets.lookup(:followed_artists, username)
    MapSet.member?(followed_artists, artist_name)
  end
end
