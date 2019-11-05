defmodule Todo.Cache do
	use GenServer

	@impl true
	def init(num_db_workers) do
		Todo.Database.start_link(num_db_workers)
		{:ok, %{}}
	end

	@impl true
	def handle_call({:server_process, todo_list_name}, _from, todo_servers) do
		case Map.fetch(todo_servers, todo_list_name) do
			{:ok, todo_server} ->
				{:reply, todo_server, todo_servers}
			:error ->
				{:ok, new_server} = Todo.Server.start_link(todo_list_name)
				{
					:reply,
					new_server,
					Map.put(todo_servers, todo_list_name, new_server)
				}
		end
	end

	def start_link(num_db_workers \\ 3) do
		IO.inspect("Starting cache")
		GenServer.start_link(__MODULE__, num_db_workers, name: __MODULE__)
	end

	def server_process(todo_list_name) do
		GenServer.call(__MODULE__, {:server_process, todo_list_name})
	end
end