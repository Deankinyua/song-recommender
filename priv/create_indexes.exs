defmodule CreateIndexes do
  @moduledoc """
  This is the second script that you should run.
  It creates indexes for different node properties.
  Indexes are used to speed up searching
  """

  require Logger

  def start do
    Logger.info("Creating relevant indexes to speed up queries...", ansi_color: :green)

    indexes = [
      """
      CREATE TEXT INDEX artist_text_index_on_name
      IF NOT EXISTS
      FOR (a:Artist) ON (a.normalizedName)
      """,
      """
      CREATE TEXT INDEX song_text_index_on_name
      IF NOT EXISTS
      FOR (s:Song) ON (s.normalizedName)
      """,
      """
      CREATE INDEX user_range_index_on_yob
      IF NOT EXISTS
      FOR (u:User) ON (u.yob)
      """
    ]

    Enum.each(indexes, &Boltx.query!(Bolt, &1))

    Logger.info("Finished creating indexes", ansi_color: :green)
  end
end

CreateIndexes.start()
