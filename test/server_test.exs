defmodule ServerTest do
  use ExUnit.Case
  
  test "Check if server is created" do
    pid = Process.whereis(:message_server)
    assert pid != nil
  end

  test "Check if server connect and disconnect works" do
    pid = Process.whereis(:message_server)
    assert {:ok, "hello"} == GenServer.call(pid, {:connect, :hello})
    assert :ok == GenServer.call(pid, {:disconnect, :hello})
  end
end
