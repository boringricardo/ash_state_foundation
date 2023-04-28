defmodule Foundation.Feature.Snapshot do
  use Ash.Resource,
    extensions: [AshStateMachine]

  # new bits follow here
  state_machine do
    initial_states([:pending])
    default_initial_state(:pending)

    transitions do
      transition(:initialize, from: :pending, to: :running)
      transition(:pause, from: :running, to: :stopped)
      transition(:resume, from: :stopped, to: :running)
      transition(:destroy, from: [:running, :stopped], to: :deleted)
      transition(:error, from: [:pending, :running, :stopped], to: :error)
    end
  end

  actions do
    create :closed do
      accept [:name]
    end

    update :resume do
      # accept []
      # we change the set_attribute to transition_state
      # change set_attribute(:status, :running)
      change transition_state(:running)

      # FYI, we can still do any other Ash things as usual during the
      # action. Only the transition_state will be validated agains our
      # defined transitions above
    end

    # also adding a few more actions here so our new transitions are
    # represented:
    update :initialize do
      change transition_state(:running)
    end

    update :pause do
      change transition_state(:stopped)
    end

    update :destroy do
      change transition_state(:deleted)
    end

    update :error do
      accept [:error_state, :message]
      change transition_state(:error)
    end
  end

  changes do
    # here we can catch any changeset errors and transition to the
    # error state
    change after_transaction(fn
             changeset, {:ok, result} ->
               {:ok, result}

             changeset, {:error, error} ->
               message = Exception.message(error)

               changeset.data
               |> Ash.Changeset.for_update(:error, %{
                 message: message,
                 error_state: changeset.data.state
               })
               |> Foundation.Feature.update!()
           end),
           on: [:update]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string

    # there will be a :state attribute added to the resource for us
    # so we no longer need :status
    # attribute :status, :atom do
    # 	constraints [one_of: [:pending, :running, :stopped]]
    #
    # 	default :pending
    #
    # 	allow_nil? false
    # end

    attribute :message, :string
    attribute :error_state, :string
  end
end
