defmodule KvStore do
	defp init do
		%{}
	end

	defp handle_call({:put, key, value}, state) do
		{:ok, Map.put(state, key, value)}
	end

	defp handle_call({:get, key}, state) do
		{Map.get(state, key), state}
	end

	defp handle_cast({:put, key, value}, state) do
		Map.put(state, key, value)
	end

	def start do
		GenericServer.start(KvStore)
	end

	def put(pid, key, value) do
		GenericServer.cast(pid, {:put, key, value})
	end

	def get(pid, key) do
		GenericServer.call(pid, {:get, key})
	end
end