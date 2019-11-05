defmodule GenericServerTest do
  use ExUnit.Case
  doctest GenericServer

  test "greets the world" do
    assert GenericServer.hello() == :world
  end
end
