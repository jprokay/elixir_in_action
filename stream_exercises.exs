defmodule StreamExercises do
	@moduledoc """
	Chapter 3 exercises for querying files for line level info
	"""

	@spec lines_length!(path :: String.t) :: [integer]
	@doc "Returns the length of each line in a file"
	def lines_length!(path) do
		File.stream!(path)
		|> Stream.map(&(String.length(&1)))
	end

	@spec longest_line_length!(path :: String.t) :: integer
	@doc "Returns the length of the longest line in a file"
	def longest_line_length!(path) do
		lines_length!(path)
		|> Enum.reduce(0, &max/2)
	end

	@spec longest_line!(path :: String.t) :: String.t
	@doc "Returns the contents of the longest line in a file"
	def longest_line!(path) do
		{_, content} = File.stream!(path)
		|> Stream.map(&({String.length(&1), &1}))
		|> Enum.max_by(fn {len, _} -> len end)
		content
	end

	@spec words_per_line!(path :: String.t) :: [integer]
	@doc "Returns the number of words per line in a file"
	def words_per_line!(path) do
		File.stream!(path)
		|> Stream.map(&(length(String.split(&1))))
	end
end

path = "./list_exercises.exs"
lens = StreamExercises.lines_length!(path)
lens |>
Stream.with_index |>
Enum.each(fn {line_length, line_num} ->
	IO.puts("Line #{line_num + 1}.length = #{line_length}")
end)
longest = StreamExercises.longest_line_length!(path)
IO.puts(longest)

IO.puts(StreamExercises.longest_line!(path))
words = StreamExercises.words_per_line!(path)
words |>
Stream.with_index |>
Enum.each(fn {word_count, line_num} ->
	IO.puts("Line #{line_num + 1} contains #{word_count} words")
end)