defmodule Foundation.Feature do
  use Ash.Api

  resources do
    # defines a set of resources that can be used with this API
    registry Foundation.Feature.Registry
  end
end
