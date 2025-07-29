defmodule Elli.Protocol.Request do
  @type t :: %__MODULE__{
          method: String.t(),
          path: String.t(),
          version: String.t(),
          headers: map(),
          body: String.t()
        }
  @enforce_keys [:method, :path, :version]
  defstruct [:method, :path, :version, headers: %{}, body: ""]
end
