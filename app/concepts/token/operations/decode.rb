# frozen_string_literal: true

require 'dry/transaction/operation'
require 'jwt'

module Sanchin
  module TokenConcept
    module Operations
      # Token parsing operation.
      class Decode
        include Dry::Transaction::Operation

        def call(token)
          claims, _headers = JWT.decode(token, ENV['JWT_SECRET'], true, algorithm: 'HS256')
          Success id: claims['sub'], version: claims['version']
        rescue JWT::DecodeError
          Failure :invalid
        end
      end
    end
  end
end
