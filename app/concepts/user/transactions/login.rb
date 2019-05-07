# frozen_string_literal: true

require 'dry/transaction'

module Sanchin
  module UserConcept
    module Transactions
      # Login as a user given a login and password couple.
      class Login
        include Dry::Transaction(container: Container)

        step :find
        step :authenticate
        step :tokenize

        private

        def find(login:, password:)
          raise ArgumentError unless login

          user = User.where(login: login).first!
          Success user: user, plaintext: password
        rescue
          # NOTE: hash a dummy password so that a username failure take about
          # the same time as a password failure.
          _ = Container['password'].create(password)
          Failure :not_found
        end

        def authenticate(user:, plaintext:)
          if user.password.is_password?(plaintext)
            Success user
          else
            Failure :wrong_password
          end
        end

        def tokenize(user)
          operation = TokenConcept::Operations::Encode.new
          operation.call(id: user.id, version: user.version)
        end
      end
    end
  end
end
