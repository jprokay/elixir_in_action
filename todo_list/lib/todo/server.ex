defmodule Todo.Server do
	use GenServer

	@impl true
	def init(list_name) do
		{:ok, {list_name, Todo.Database.get(list_name) || Todo.List.new()}}
	end

	@impl true
	def handle_call({:list, date}, _from, {name, todo_list}) do
		{:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
	end

	@impl true
	def handle_cast({:put, entry}, {name, todo_list}) do
		new_list = Todo.List.add_entry(todo_list, entry)
		Todo.Database.store(name, new_list)
		{:noreply, {name, new_list}}
	end

	@impl true
	def handle_cast({:update, entry_id, updater_fn}, {name, todo_list}) do
		new_list = Todo.List.update_entry(todo_list, entry_id, updater_fn)
		{:noreply, {name, new_list}}
	end

	@impl true
	def handle_cast({:delete, entry_id}, {name, todo_list}) do
		new_list = Todo.List.delete_entry(todo_list, entry_id)
		{:noreply, {name, new_list}}
	end

	def start_link(list_name) do
		GenServer.start_link(__MODULE__, list_name)
	end

	def add_entry(pid, entry) do
		GenServer.cast(pid, {:put, entry})
	end

	def entries(pid, date) do
		GenServer.call(pid, {:list, date})
	end

	def update_entry(pid, entry_id, updater_fn) do
		GenServer.cast(pid, {:update, entry_id, updater_fn})
	end

	def delete_entry(pid, entry_id) do
		GenServer.cast(pid, {:delete, entry_id})
	end
end