# frozen_string_literal: true

require 'dry/transaction/operation'
require 'jwt'

module Sanchin
  module TokenConcept
    module Operations
      # Token creator operation.
      class Encode
        include Dry::Transaction::Operation

        def call(id:, version:)
          payload = { sub: id, version: version }
          Success JWT.encode(payload, ENV['JWT_SECRET'], 'HS256')
        end
      end
    end
  end
end
