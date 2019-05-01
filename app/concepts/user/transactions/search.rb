# frozen_string_literal: true

require 'dry/transaction'

module Sanchin
  module UserConcept
    module Transactions
      # Search many users.
      class Search
        include Dry::Transaction(container: Container)

        map   :search
        check :authorize

        private

        def search(_input)
          User.order(:created_at).all
        end

        def authorize(_users, _authenticated)
          true
        end
      end
    end
  end
end
