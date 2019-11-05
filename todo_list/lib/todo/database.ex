require Logger

defmodule Todo.Database do
	use GenServer, Logger

	@db_dir "/persist"

	@impl true
	def init(num_workers) do
		File.mkdir_p!(@db_dir) # Makes directory. Throws error if fail

		{:ok, {num_workers, init_workers(%{}, num_workers)}}
	end

	defp init_workers(worker_map, num_workers) when num_workers > 0 do
		case Todo.Database.Worker.start_link(@db_dir) do
			{:ok, pid} ->
				IO.inspect("Started worker #{num_workers}: #{inspect pid}")
				# Subtract workers by 1 to ensure map keys go from [0, num_workers)
				init_workers(Map.put(worker_map, num_workers - 1, pid),
					num_workers - 1)
			_ -> worker_map
		end
	end

	defp init_workers(worker_map, num_workers) when num_workers <= 0 do
		worker_map
	end

	def start_link(num_workers \\ 3) do
		IO.inspect("Starting database with #{num_workers}")
		GenServer.start_link(__MODULE__, num_workers, name: __MODULE__)
	end

	def get(key) do
		GenServer.call(__MODULE__, {:get, key})
	end

	def store(key, data) do
		GenServer.cast(__MODULE__, {:store, key, data})
	end

	@impl true
	def handle_cast({:store, key, data}, {num_workers, workers}) do
		choose_worker(num_workers, workers, key)
		|> Todo.Database.Worker.store(key, data)

		{:noreply, {num_workers, workers}}
	end

	@impl true
	def handle_call({:get, key}, _, {num_workers, workers}) do 
		worker = choose_worker(num_workers, workers, key)

		{:reply, Todo.Database.Worker.get(worker, key),
			{num_workers, workers}}
	end

	defp choose_worker(num_workers, workers, key) do
		Map.get(workers, :erlang.phash2(key, num_workers))
	end

end