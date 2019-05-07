# frozen_string_literal: true

require 'dry/transaction'
require 'jwt'

module Sanchin
  module UserConcept
    module Transactions
      # Authenticate as a user given a token created by Login.
      class Authenticate
        include Dry::Transaction(container: Container)

        step :decode
        step :find
        step :validate

        private

        def decode(token)
          TokenConcept::Operations::Decode.new.call(token)
        end

        def find(id:, version:)
          user = User.where(id: id).first!
          Success user: user, version: version
        rescue
          Failure :not_found
        end

        def validate(user:, version:)
          if user.version == version
            Success user
          else
            Failure :outdated
          end
        end
      end
    end
  end
end
