defmodule CreateConstraints do
  require Logger

  def start do
    Logger.info("Creating relevant constraints; primary keys and data type constraints",
      ansi_color: :green
    )

    constraints = [
      """
      CREATE CONSTRAINT user_unique_name IF NOT EXISTS
      FOR (u:User)
      REQUIRE u.name IS UNIQUE
      """
    ]

    Enum.each(constraints, &Boltx.query!(Bolt, &1))

    Logger.info("Finished creating constraints", ansi_color: :green)
  end
end

CreateConstraints.start()
