defmodule Demo.Main do
  @moduledoc """
  Simple module to demonstrate manual server startup.
  
  This can be used for testing the server without starting the full application.
  """
  
  def start do
    # Start the Elli application manually
    Application.ensure_all_started(:elli)
    
    # Start our demo server
    Elli.start_server(
      port: 4000,
      acceptors: 5,
      handler: Demo.RequestHandler
    )
  end
  
  def stop do
    Elli.stop()
  end
end
