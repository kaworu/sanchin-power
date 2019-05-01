# frozen_string_literal: true

require 'dry/transaction'

module Sanchin
  module UserConcept
    module Transactions
      # Find a specific user given its id.
      class Find
        include Dry::Transaction(container: Container)

        step  :find
        check :authorize

        private

        def find(input)
          Success User.where(id: input).first!
        rescue
          Failure :not_found
        end

        def authorize(_user, _authenticated)
          true
        end
      end
    end
  end
end
