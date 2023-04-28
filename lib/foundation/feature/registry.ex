defmodule Foundation.Feature.Registry do
  use Ash.Registry

  entries do
    entry Foundation.Feature.Snapshot
  end
end
