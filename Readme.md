# Elli Http

This is just a minimal HTTP server for learning purposes.

## Example

You can checkout the demo application under [demo](https://github.com/pangeorg/elli_http/tree/main/demo).

The demo application starts the Elli.ServerSupervisor process.
This in turn starts 2 children, the Server, which handles the socket connection, and the acceptor supervisor.
The server also starts 10 Acceptors under the acceptor supervisor which handle each incoming connection.
