defmodule GenTodoList do
	
	def init do
		TodoList.new()
	end

	def start do
		GenericServer.start(GenTodoList)
	end

	def add_entry(pid, entry) do
		GenericServer.cast(pid, {:add, entry})
	end

	def update_entry(pid, id, updater_fn) do
		GenericServer.cast(pid, {:update, id, updater_fn})
	end

	def delete_entry(pid, id) do
		GenericServer.cast(pid, {:delete, id})
	end

	def entries(pid, date) do
		GenericServer.call(pid, {:list, date})
	end

	def handle_cast({:add, entry}, todo_list) do
		TodoList.add_entry(todo_list, entry)
	end

	def handle_cast({:update, id, updater_fn}, todo_list) do
		TodoList.update_entry(todo_list, id, updater_fn)
	end

	def handle_cast({:delete, id}, todo_list) do
		TodoList.delete_entry(todo_list, id)
	end

	def handle_call({:list, date}, todo_list) do
		{TodoList.entries(todo_list, date), todo_list}
	end
end