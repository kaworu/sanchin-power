# frozen_string_literal: true

require 'dry/transaction'

module Sanchin
  module UserConcept
    module Transactions
      # Save a new user in the database.
      class Create
        include Dry::Transaction(container: Container)

        check :authorize
        step  :validate
        map   :create

        private

        def authorize(_input, _authenticated)
          true
        end

        def validate(input)
          Schemas::Create.call(input).to_monad
        end

        def create(validated)
          User.create(validated)
        end
      end
    end
  end
end
