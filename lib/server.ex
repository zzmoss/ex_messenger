defmodule ExMessenger.Server do
  use GenServer

  def start_link([]) do
    :gen_server.start_link({ :local, :message_server }, __MODULE__, [], [])
  end

  def init([]) do
      { :ok, HashDict.new() }
  end

  def handle_call({:connect, nick}, {pid, _}, users) do
    newusers = users |> HashDict.put(nick, node(pid))
    userlist = newusers |> HashDict.keys |> Enum.join ":"
    {:reply, {:ok, userlist}, newusers}
  end

  def handle_call({:disconnect, nick}, {_, _}, users) do
    newusers = users |> HashDict.delete nick
    {:reply, :ok, newusers}
  end
    
  defp broadcast(users, from, msg) do
    Enum.each(users, fn { _, node } -> GenServer.cast({:message_handler, node}, {:message, from, msg}) end)
  end

  def handle_cast({:say, nick, msg}, users) do
    ears = HashDict.delete(users, nick)
    broadcast(ears, nick, "#{msg}")
    {:noreply, users}
  end

  def handle_cast({:private_message, nick, receiver, msg}, users) do
    case users |> HashDict.get receiver do
      nil -> :ok
      r -> GenServer.cast({:message_handler, r}, {:message, nick, "(#{msg})"})
    end
    {:noreply, users}
  end

end
