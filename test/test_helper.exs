ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SongRecommender.Repo, :manual)

{:ok, _} = Testcontainers.start_link()

wait_for_bolt = Testcontainers.LogWaitStrategy.new(~r/.*Bolt enabled on .*:7687/, 120_000)

config = %Testcontainers.Container{
  image: "neo4j:2026.04.0-community",
  environment: %{NEO4J_AUTH: "neo4j/test_password"},
  exposed_ports: [{7474, 7474}, {7687, 7687}],
  wait_strategies: [wait_for_bolt]
}

{:ok, _container} = Testcontainers.start_container(config)

{:ok, _} =
  Boltx.start_link(Application.get_env(:boltx, Bolt))
