defmodule FoundationTest do
  use ExUnit.Case
  doctest Foundation

  test "greets the world" do
    assert Foundation.hello() == :world
  end
end
