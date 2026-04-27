defmodule CreateConstraints do
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
      REQUIRE a.name IS :: STRING
      """,
      """
      CREATE CONSTRAINT song_string_name IF NOT EXISTS
      FOR (s:Song)
      REQUIRE s.name IS :: STRING
      """
    ]

    Enum.each(constraints, &Boltx.query!(Bolt, &1))

    Logger.info("Finished creating constraints", ansi_color: :green)
  end
end

CreateConstraints.start()
