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
        step  :create

        private

        def authorize(_input, _authenticated)
          true
        end

        def validate(input)
          Schemas::Create.call(input).to_monad
        end

        def create(validated)
          Success User.new(validated).save
        rescue Sequel::UniqueConstraintViolation
          Failure login: 'is already taken'
        end
      end
    end
  end
end
