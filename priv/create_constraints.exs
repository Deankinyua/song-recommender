defmodule CreateConstraints do
  @moduledoc """
  This is the first script that you should run if
  you're building the data yourself. It creates constraints for
  different node properties.
  """

  require Logger

  def start do
    Logger.info("Creating relevant constraints; primary keys and data type constraints",
      ansi_color: :green
    )

    constraints = [
      """
      CREATE CONSTRAINT artist_unique_name IF NOT EXISTS
      FOR (a:Artist)
      REQUIRE a.name IS UNIQUE
      """,
      """
      CREATE CONSTRAINT song_unique_id IF NOT EXISTS
      FOR (s:Song)
      REQUIRE s.id IS UNIQUE
      """,
      """
      CREATE CONSTRAINT genre_unique_name IF NOT EXISTS
      FOR (g:Genre)
      REQUIRE g.name IS UNIQUE
      """,
      """
      CREATE CONSTRAINT user_unique_name IF NOT EXISTS
      FOR (u:User)
      REQUIRE u.name IS UNIQUE
      """,
      """
      CREATE CONSTRAINT artist_string_name IF NOT EXISTS
      FOR (a:Artist)
      REQUIRE a.normalizedName IS :: STRING
      """,
      """
      CREATE CONSTRAINT song_string_name IF NOT EXISTS
      FOR (s:Song)
      REQUIRE s.normalizedName IS :: STRING
      """
    ]

    Enum.each(constraints, &Boltx.query!(Bolt, &1))

    Logger.info("Finished creating constraints", ansi_color: :green)
  end
end

CreateConstraints.start()
