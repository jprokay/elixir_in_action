defmodule ListExercises do
	@moduledoc "Tail recursive list exercises (chapter 3)"

	@spec sum([number]) :: number
	@doc "Calculates the sum of the values in the list"
	def sum(list) do
		do_sum(0, list)
	end

	defp do_sum(current_sum, []) do
		current_sum
	end

	defp do_sum(current_sum, [head | tail]) do
		new_sum = current_sum + head
		do_sum(new_sum, tail)
	end

	@spec list_len([number]) :: number
	@doc "Calculates the length of the list"
	def list_len(list) do
		do_len(0, list)
	end

	defp do_len(current_len, []) do
		current_len
	end

	defp do_len(current_len, [_ | tail]) do
		do_len(current_len + 1, tail)
	end

	@spec range(from :: integer, to :: integer) :: [number]
	@doc "Creates a list containing all numbers between [from, to]"
	def range(from, to) when is_integer(from) and is_integer(to) and from < to do
		do_range([], from, to)
	end
	
	defp do_range(in_range, from, to) when is_number(from) and is_number(to) and from === to do
		[to | in_range]
	end

	defp do_range(in_range, from, to) when is_number(from) and is_number(to) and from < to do
		do_range([from | in_range], from + 1, to)
	end

	@spec positives([number]) :: [number]
	@doc "Returns a list of all positive numbers from the input"
	def positives(nums) do
		do_positive([], nums)
	end

	defp do_positive(positives, []) do
		positives
	end

	defp do_positive(positives, [head | tail]) when head > 0 do
		do_positive([head | positives], tail)
	end

	defp do_positive(positives, [head | tail]) when head <= 0 do
		do_positive(positives, tail)
	end
end

list = [1,2,3,4]
IO.puts(ListExercises.sum(list))
IO.puts(ListExercises.list_len(list))

ranged = ListExercises.range(1, 4)
IO.puts(ListExercises.sum(ranged))
IO.puts(ListExercises.list_len(ranged))

mixed = [0, 1, -5, 2, -10, -4, 3, -1000, 4]
pos = ListExercises.positives(mixed)
IO.puts(ListExercises.sum(pos))
IO.puts(ListExercises.list_len(pos))