# frozen_string_literal: true

require 'dry-validation'
require 'lib/types'

module Sanchin
  module UserConcept
    module Schemas
      # User creation Schema.
      Create = Dry::Validation.Params do
        configure { config.type_specs = true }
        required(:firstname, Types::StrippedCapitalized) { str? & size?(1..255) }
        required(:lastname, Types::StrippedCapitalized)  { str? & size?(1..255) }
        required(:birthdate, Types::Params::Date)        { date? & lt?(Date.today) }
        optional(:gender, Types::StrippedDowncased)      { str? & included_in?(%w[female male]) }
        optional(:login, Types::StrippedDowncased)       { str? & size?(3..255) }
        optional(:password, Types::String)               { str? & min_size?(6) }

        rule(password: %i[login password]) do |login, password|
          login.filled?.then password.filled?
        end

        rule(login: %i[login password]) do |login, password|
          password.filled?.then login.filled?
        end
      end
    end
  end
end
