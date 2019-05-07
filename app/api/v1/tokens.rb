# frozen_string_literal: true

require 'api/v1/base'

module Sanchin
  module APIv1
    # Sanchin API tokens concept related end-points.
    class Tokens < Base
      # API token creation end-point.
      post '/api/v1/tokens', authenticated: false do
        username, password = basic_auth
        transaction = UserConcept::Transactions::Login.new
        transaction.call(login: username, password: password) do |on|
          on.success do |token|
            status :created
            json(access_token: token, token_type: 'bearer')
          end
          on.failure do
            status :unauthorized
            response.headers['WWW-Authenticate'] = 'Basic charset="UTF-8"'
            halt
          end
        end
      end
    end
  end
end
