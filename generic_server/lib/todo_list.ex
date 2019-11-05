defmodule TodoServer do
  def start do
    spawn(fn ->
      Process.register(self(), :todo_server)
      loop(TodoList.new())
    end)
  end

  def loop(todo_list) do
    new_tl =
      receive do
        message ->
          process_message(todo_list, message)
      end
    loop(new_tl)
  end

  def add_entry(entry), do: send(:todo_server, {:add_entry, entry})

  def update_entry(id, updater_fn), do: send(:todo_server, {:update_entry, id, updater_fn})

  def delete_entry(id), do: send(:todo_server, {:delete_entry, id})

  def entries(date) do
    send(:todo_server, {:entries, self(), date})

    receive do
      {:todo_list, todo_list} -> todo_list
    after
      5000 -> {:error, :timeout}
    end
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_list, TodoList.entries(todo_list, date)})
    todo_list
  end

  defp process_message(todo_list, {:update_entry, id, updater_fn}) do
    TodoList.update_entry(todo_list, id, updater_fn)
  end

  defp process_message(todo_list, {:delete_entry, id}) do
    TodoList.delete_entry(todo_list, id)
  end
end

defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries,
      %TodoList{},
      fn entry, list_acc ->
        add_entry(list_acc, entry)
      end
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries,
      todo_list.auto_id,
      entry)
    %TodoList{todo_list |
      entries: new_entries,
      auto_id: todo_list.auto_id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, entry_id, updater_fn) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error -> todo_list
      {:ok, old_entry} ->
        new_entry = updater_fn.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end
end


defmodule TodoList.CsvImporter do
  
  # First attempt. Problem: too much happening!
  # Break it apart into small chunks and PIPE IT
  defp parse_line(line) do
    [date, title] = String.split(line, ",")
    [year, month, day] = Enum.map(String.split(date, "/"), &String.to_integer/1)
    case Date.new(year, month, day) do
      {:ok, parsed} -> %{date: parsed, title: String.replace(title, "\n", "")}
      {:error, reason} -> {:error, reason}
    end
  end

  def import(file_name) do
    file_name
    |> read_lines
    |> create_entries
    |> TodoList.new()
  end

  defp read_lines(file_name) do
    file_name
    |> File.stream!()
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  defp create_entries(lines) do
    lines
    |> Stream.map(&extract_fields/1)
    |> Stream.map(&create_entry/1)
  end

  defp extract_fields(line) do
    line
    |> String.split(",")
    |> convert_date
  end

  defp convert_date([date_string, title]) do
    {parse_date(date_string), title}
  end

  defp parse_date(date_string) do
    [year, month, day] =
      date_string
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)
    {:ok, date} = Date.new(year, month, day)
    date
  end

  defp create_entry({date, title}) do
    %{date: date, title: title}
  end
end