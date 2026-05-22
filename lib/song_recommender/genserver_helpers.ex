defmodule SongRecommender.GenserverHelpers do
  @moduledoc """
  Helper functions for the genservers
  """

  alias SongRecommender.EngineQueueRegistry

  @type message :: any()
  @type request_type :: atom()
  @type server_name :: String.t()

  @doc """
  Encapsulates making requests to genservers via the registry.
  """

  @spec make_genserver_request(server_name(), request_type(), message()) :: :ok | term()
  def make_genserver_request(server_name, request_type, message) when request_type == :call do
    server_name
    |> via_registry()
    |> GenServer.call(message)
  end

  def make_genserver_request(server_name, _request_type, message) do
    server_name
    |> via_registry()
    |> GenServer.cast(message)
  end

  defp via_registry(name), do: {:via, Registry, {EngineQueueRegistry, name}}
end
