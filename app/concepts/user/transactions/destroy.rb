# frozen_string_literal: true

require 'dry/transaction'

module Sanchin
  module UserConcept
    module Transactions
      # Remove a user from the database given its id.
      class Destroy
        include Dry::Transaction(container: Container)

        around :transaction, with: 'database.transaction'
        step  :find
        check :authorize
        check :match
        tee   :destroy

        private

        def find(input)
          Success User.where(id: input).for_update.first!
        rescue
          Failure :not_found
        end

        def authorize(_user, _authenticated)
          true
        end

        def match(user, last_seen)
          last_seen && user.last_update <= last_seen
        end

        def destroy(user)
          user.destroy
        end
      end
    end
  end
end
