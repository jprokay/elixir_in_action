defmodule Todo.System do
	use Supervisor

	def start_link do
		Supervisor.start_link(__MODULE__, nil)
	end

	@impl true
	def init(_) do
		IO.inspect("Starting system")
		Supervisor.init([{Todo.Cache, 5}], strategy: :one_for_one)
	end
end