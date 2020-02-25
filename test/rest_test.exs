defmodule RestTest do
  use ExUnit.Case
  doctest Rest

  test "greets the world" do
    assert Rest.hello() == :world
  end
end
