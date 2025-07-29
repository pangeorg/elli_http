defmodule Demo.RequestHandler do
  @moduledoc """
  Demo request handler that showcases various HTTP responses.
  """
  
  alias Elli.Protocol.{Request, Response}
  
  def handle_request(%Request{method: "GET", path: "/"}) do
    html = """
    <!DOCTYPE html>
    <html>
    <head>
      <title>Elli Demo Server</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .endpoint { margin: 10px 0; padding: 10px; background: #f5f5f5; }
        code { background: #eee; padding: 2px 4px; }
      </style>
    </head>
    <body>
      <h1>🚀 Elli HTTP Server Demo</h1>
      <p>Welcome to the Elli HTTP server demonstration!</p>
      
      <h2>Available Endpoints:</h2>
      <div class="endpoint">
        <strong>GET /</strong> - This page
      </div>
      <div class="endpoint">
        <strong>GET /health</strong> - Health check
      </div>
      <div class="endpoint">
        <strong>GET /info</strong> - Server information (JSON)
      </div>
      <div class="endpoint">
        <strong>GET /time</strong> - Current server time
      </div>
      <div class="endpoint">
        <strong>POST /echo</strong> - Echo the request body
      </div>
      <div class="endpoint">
        <strong>GET /error</strong> - Trigger a server error (for testing)
      </div>
      
      <p>Try: <code>curl http://localhost:#{port()}/info</code></p>
    </body>
    </html>
    """
    
    Response.ok(html, %{"content-type"=> "text/html"})
  end
  
  def handle_request(%Request{method: "GET", path: "/health"}) do
    Response.ok("OK")
  end
  
  def handle_request(%Request{method: "GET", path: "/time"}) do
    time = DateTime.utc_now() |> DateTime.to_string()
    Response.ok("Current server time: #{time}")
  end
  
  def handle_request(%Request{method: "POST", path: "/echo", body: body}) do
    Response.ok(body || "No body provided", %{"content-type" => "text/plain"})
  end
  
  def handle_request(%Request{method: "GET", path: "/error"}) do
    # Intentionally cause an error for testing
    raise "This is a test error!"
  end
  
  def handle_request(%Request{path: path, method: method}) do
    message = "Method #{method} not allowed for path #{path}"
    Response.not_found(message)
  end
  
  defp port do
    System.get_env("PORT", "4000")
  end
end
