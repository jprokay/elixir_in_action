defmodule Todo.Database.Worker do
	use GenServer

	@impl true
	def init(db_path) do
		{:ok, db_path}
	end

	def start_link(db_path) do
		GenServer.start_link(__MODULE__, db_path)
	end

	def get(pid, key) do
		GenServer.call(pid, {:get, key})
	end

	def store(pid, key, data) do
		GenServer.cast(pid, {:store, key, data})
	end

	@impl true
	def handle_call({:get, key}, _from, db_dir) do
		data = case File.read(file_name(db_dir, key)) do
			{:ok, contents} -> :erlang.binary_to_term(contents)
			_ -> nil
		end

		{:reply, data, db_dir}
	end

	@impl true
	def handle_cast({:store, key, data}, db_dir) do
		db_dir
		|> file_name(key)
		|> File.write!(:erlang.term_to_binary(data))

		{:noreply, db_dir}
	end

	defp file_name(db_dir, key) do
		Path.join(db_dir, to_string(key))
	end
end