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
        map   :hash
        step  :create

        private

        def authorize(_input, _authenticated)
          true
        end

        def validate(input)
          Schemas::Create.call(input).to_monad
        end

        def hash(validated)
          if validated[:password]
            cleartext = validated[:password]
            hashed = Container['password'].create cleartext
            validated[:password] = hashed
          end
          validated
        end

        def create(validated)
          Success User.create(validated)
        rescue
          Failure login: 'is already taken'
        end
      end
    end
  end
end
