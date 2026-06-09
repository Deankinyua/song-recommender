defmodule SongRecommender.Songs do
  @moduledoc """
  Tracks how users listen to songs. Fetches songs with certain characteristics.
  """

  import Ecto.Changeset, only: [apply_action!: 2]

  alias SongRecommender.PubSub
  alias SongRecommender.Songs.MusicalProperties
  alias SongRecommender.Songs.Song

  @type attrs :: map()
  @type bolt_response :: Boltx.Response.t()
  @type genre_name :: String.t()
  @type listening_duration :: integer()
  @type musical_properties :: MusicalProperties.t()
  @type song :: Song.t()
  @type song_and_listening_time :: [song_id() | listening_duration()]
  @type song_id :: String.t()
  @type taste_profile :: map()
  @type username :: String.t()

  @doc """
   Subscribes to song events.

  ## Examples

      iex> subscribe("Kennedy")
      :ok

  """
  @spec subscribe(username()) :: :ok
  def subscribe(username) do
    Phoenix.PubSub.subscribe(PubSub, "songs-#{username}")
  end

  @doc """
  Broadcasts a message with newly recommended songs.

  ## Examples

      iex> broadcast("Robert", recommended_songs)
      :ok

  """
  @spec broadcast(username(), [song()]) :: :ok
  def broadcast(username, recommended_songs) do
    Phoenix.PubSub.broadcast(
      PubSub,
      "songs-#{username}",
      {:new_recommended_songs, recommended_songs}
    )
  end

  @doc """
  Returns a song with its details
  """

  @spec get_song!(song_id()) :: song() | nil
  def get_song!(song_id) do
    case song_by_id(song_id) do
      nil ->
        nil

      %{"song" => song_attrs} ->
        %Song{}
        |> Song.changeset(song_attrs)
        |> apply_action!(:update)
    end
  end

  @doc """
  Returns the musical properties (valence, danceability, liveness e.t.c) of a song
  """

  @spec get_song_musical_properties(song_id()) :: musical_properties() | nil
  def get_song_musical_properties(song_id) do
    case song_by_id(song_id) do
      nil ->
        nil

      %{"song" => song_attrs} ->
        %MusicalProperties{}
        |> MusicalProperties.changeset(song_attrs)
        |> apply_action!(:update)
    end
  end

  @doc """
  Returns multiple songs in one go. Takes a list of song_ids.
  """

  @spec get_multiple_songs([song_id()]) :: [song()]
  def get_multiple_songs(song_ids) do
    %Boltx.Response{results: song_data} =
      Boltx.query!(
        Bolt,
        """
        UNWIND $song_ids AS song_id
        MATCH (artist:Artist)-[:SANG]->(song:Song {id: song_id})-[:BELONGS_TO]->(genre:Genre)
        RETURN song { .*, duration_ms: song.durationMs },
               artist { .*, id: randomUUID(), monthly_listeners: artist.monthlyListeners },
               genre { .* }
        """,
        %{song_ids: song_ids}
      )

    song_data
    |> Enum.map(&process_song_data(&1))
    |> Enum.shuffle()
  end

  defp song_by_id(song_id) do
    Bolt
    |> Boltx.query!(
      """
      MATCH (s:Song {id: $song_id})
      RETURN s { .*, duration_ms: s.durationMs } as song
      """,
      %{song_id: song_id}
    )
    |> Boltx.Response.first()
  end

  @doc """
  Returns the duration a user has listened to a particualar song
  """

  @spec get_song_listening_time(song_id(), username()) :: listening_duration()
  def get_song_listening_time(song_id, username) do
    case get_listening_time(song_id, username) do
      nil ->
        nil

      %{"listening_time" => listening_time} ->
        listening_time
    end
  end

  defp get_listening_time(song_id, username) do
    Bolt
    |> Boltx.query!(
      """
      MATCH (:Song {id: $song_id})<-[lt:LISTENED_TO]-(:User {name: $name})
      RETURN lt.durationPlayedMs AS listening_time
      """,
      %{song_id: song_id, name: username}
    )
    |> Boltx.Response.first()
  end

  @doc """
  Listen's to the most popular song from a given genre.
  It first finds songs the user hasn't listened to already.
  Finding one, it adds the LISTENED_TO relationship to it with the
  durationPlayedMs property being the song duration.
  After exhausting all songs it will retrieve only the songs that were played less
  than 3 times. Then, it will update the durationPlayedMs property
  each time setting it to the former value + the song duration.
  """

  @spec listen_from_genre(username(), genre_name()) :: bolt_response()
  def listen_from_genre(username, genre) do
    Boltx.query!(
      Bolt,
      """
      MATCH (user:User {name: $username})
      MATCH (genre:Genre {name: $genre})
      OPTIONAL MATCH (song:Song)-[:BELONGS_TO]->(genre)
      WHERE NOT EXISTS { (user)-[:LISTENED_TO]->(song) }
      WITH song, user, genre
        ORDER BY song.popularity DESC
        LIMIT 1
      CALL (*) {
        WHEN song IS NULL THEN {
          MATCH (user)-[l:LISTENED_TO]->(listenedToSong:Song)-[:BELONGS_TO]->(genre)
          WHERE l.durationPlayedMs < listenedToSong.durationMs * 3
          RETURN listenedToSong AS finalSong
          ORDER BY finalSong.popularity DESC
          LIMIT 1
        }
        ELSE {
          RETURN song AS finalSong
        }
      }
      MERGE (user)-[lt:LISTENED_TO]->(finalSong)
      ON CREATE SET lt.durationPlayedMs = finalSong.durationMs
      ON MATCH SET lt.durationPlayedMs = lt.durationPlayedMs + finalSong.durationMs
      SET lt.lastPlayedDate = datetime()
      """,
      %{
        genre: genre,
        username: username
      }
    )
  end

  @doc """
  Adds direct listening relationships between users and songs. It also
  adds these relationships to artists and genres which helps in the Wrapped feature
  and also checking the totalListeningTime for the user computed by going
  through all the genres of music the user has listened to.

  ## Examples

      iex> persist_user_session_history("Dean", [ ["24NvptbNKGs6sPy1Vh1O0v", 3213], ["1RjEDlhTp2iJXWPdLpa8OM", 1293] ])
       %Boltx.Response{}
  """

  @spec persist_user_session_history(username(), [song_and_listening_time()]) :: bolt_response()
  def persist_user_session_history(username, songs_listening_history) do
    Boltx.query!(
      Bolt,
      """
      MATCH (user:User {name: $username})
      UNWIND $songs_listening_history AS songAndDurationPlayed
      WITH user,
           songAndDurationPlayed[0] AS song_id,
           songAndDurationPlayed[1] AS durationPlayedMs
      MATCH (a:Artist)-[:SANG]->(song:Song {id: song_id})-[:BELONGS_TO]->(g:Genre)
      MERGE (user)-[lt:LISTENED_TO]->(song)
      ON CREATE SET lt.durationPlayedMs = durationPlayedMs
      ON MATCH SET lt.durationPlayedMs = lt.durationPlayedMs + durationPlayedMs
      SET lt.lastPlayedDate = datetime()
      MERGE (user)-[lg:LISTENED_TO_GENRE]->(g)
      ON CREATE SET lg.totalDurationPlayedMs = durationPlayedMs
      ON MATCH SET lg.totalDurationPlayedMs = lg.totalDurationPlayedMs + durationPlayedMs
      MERGE (user)-[la:LISTENED_TO_ARTIST]->(a)
      ON CREATE SET la.totalDurationPlayedMs = durationPlayedMs
      ON MATCH SET la.totalDurationPlayedMs = la.totalDurationPlayedMs + durationPlayedMs
      """,
      %{
        songs_listening_history: songs_listening_history,
        username: username
      }
    )
  end

  @doc """
  Gets songs belonging to some genres and some sang by some artists
  """

  @spec get_songs_with_genre_based_strategy(username(), taste_profile()) :: [song()]
  def get_songs_with_genre_based_strategy(
        username,
        %{artists: artists, genres: genres} = _taste_profile
      ) do
    %{nodes: artist_names, limit: artists_song_limit} = artists
    %{nodes: genre_names, limit: genres_song_limit} = genres

    %Boltx.Response{results: song_data} =
      Boltx.query!(
        Bolt,
        """
        MATCH (u:User {name: $username})

        CALL (u) {

          CALL (*) {
            MATCH (u)-[lt:LISTENED_TO]->(s:Song)-[:BELONGS_TO]->(g:Genre)
            WHERE duration.between(lt.lastPlayedDate, datetime()).hours > 9
            MATCH (a:Artist)-[:SANG]->(s)
            RETURN s AS song, a AS artist, g AS genre
            ORDER BY lt.durationPlayedMs DESC
            LIMIT 2
          }

          RETURN song, artist, genre

        UNION

          UNWIND $genres AS genreName

          CALL (*) {
            MATCH (g:Genre {name: genreName})
            OPTIONAL MATCH (s:Song)-[:BELONGS_TO]->(g)
            WHERE NOT EXISTS { (u)-[:LISTENED_TO]->(s) }
            WITH *
            ORDER BY s.popularity DESC

            CALL (*) {
              WHEN s IS NOT NULL THEN {
                MATCH (a:Artist)-[:SANG]->(s)
                RETURN a AS theArtist, s AS theSong
              }
              ELSE {
                MATCH (a:Artist)-[:SANG]->(listenedToSong:Song)-[:BELONGS_TO]->(g)
                MATCH (u)-[lt:LISTENED_TO]->(listenedToSong)
                RETURN a AS theArtist, listenedToSong AS theSong
                ORDER BY lt.lastPlayedDate
                LIMIT $genres_song_limit
              }
            }

            RETURN theSong AS song, theArtist AS artist, g AS genre
            LIMIT $genres_song_limit
          }

          RETURN song, artist, genre

        UNION

          UNWIND $artists AS artistName

          CALL (*) {
            MATCH (a:Artist {name: artistName})
            OPTIONAL MATCH (a)-[:SANG]->(s:Song)
            WHERE NOT EXISTS { (u)-[:LISTENED_TO]->(s) }
            WITH *
            ORDER BY s.popularity DESC

            CALL (*) {
              WHEN s IS NOT NULL THEN {
                MATCH (s)-[:BELONGS_TO]->(g:Genre)
                RETURN g, s AS theSong
              }
              ELSE {
                MATCH (a)-[:SANG]->(listenedToSong:Song)-[:BELONGS_TO]->(g:Genre)
                MATCH (u)-[lt:LISTENED_TO]->(listenedToSong)
                RETURN g, listenedToSong AS theSong
                ORDER BY lt.lastPlayedDate
                LIMIT $genres_song_limit
              }
            }

            RETURN a AS artist, g AS genre, theSong AS song
            LIMIT $genres_song_limit
          }

          RETURN song, artist, genre

        }

        RETURN song { .*, duration_ms: song.durationMs },
               artist { .*, id: randomUUID(), monthly_listeners: artist.monthlyListeners },
               genre { .* }
        """,
        %{
          artists: artist_names,
          artists_song_limit: artists_song_limit,
          genres: genre_names,
          genres_song_limit: genres_song_limit,
          username: username
        }
      )

    song_data
    |> Enum.map(&process_song_data(&1))
    |> Enum.shuffle()
  end

  @doc """
  Gets songs musical properties. Returns a list with %MusicalProperties{}
  """

  @spec get_songs_properties(map()) :: [musical_properties()]
  def get_songs_properties(song_information) do
    %Boltx.Response{results: song_musical_properties} =
      Boltx.query!(
        Bolt,
        """
        CALL () {

          MATCH (a:Artist)-[:SANG]->(s:Song)-[:BELONGS_TO]->(g:Genre {name: $genre_name})
          WHERE a.name <> $artist_name
          RETURN s AS song
          SKIP $randomizer
          LIMIT 45

        UNION

          MATCH (a:Artist {name: $artist_name})-[:SANG]->(s:Song)
          WHERE s.id <> $id
          RETURN s AS song
          SKIP $randomizer
          LIMIT 5

        UNION

          MATCH (s:Song)
          WHERE s.normalizedName CONTAINS toLower($artist_name) AND s.id <> $id
          RETURN s AS song
          SKIP $randomizer
          LIMIT 10

        }

        RETURN song { .* }

        """,
        song_information
      )

    Enum.map(song_musical_properties, &process_song_attributes(&1))
  end

  defp process_song_attributes(%{
         "song" => song_attrs
       }) do
    populate_song_musical_properties(%MusicalProperties{}, song_attrs)
  end

  defp populate_song_musical_properties(%MusicalProperties{} = properties, attrs) do
    properties
    |> MusicalProperties.changeset(attrs)
    |> apply_action!(:update)
  end

  defp process_song_data(%{
         "song" => song_attrs,
         "artist" => artist_attrs,
         "genre" => genre_attrs
       }) do
    total_song_attrs =
      song_attrs
      |> Map.put("artist", artist_attrs)
      |> Map.put("genre", genre_attrs)

    populate_song(%Song{}, total_song_attrs)
  end

  @doc """
  Updates a song struct with new attributes
  """

  @spec populate_song(song(), attrs()) :: song()
  def populate_song(%Song{} = song, attrs) do
    song
    |> Song.changeset(attrs)
    |> apply_action!(:update)
  end
end
