# frozen_string_literal: true

require 'dry-validation'
require 'lib/types'

module Sanchin
  module UserConcept
    module Schemas
      # User update Schema.
      Update = Dry::Validation.Params do
        configure { config.type_specs = true }
        optional(:firstname, Types::StrippedCapitalized) { str? & size?(1..255) }
        optional(:lastname, Types::StrippedCapitalized)  { str? & size?(1..255) }
        optional(:birthdate, Types::Params::Date)        { date? & lt?(Date.today) }
        optional(:gender, Types::StrippedDowncased)      { str? & included_in?(%w[female male]) }
        optional(:login, Types::StrippedDowncased)       { str? & size?(3..255) }
        optional(:password, Types::String)               { str? & min_size?(6) }
      end
    end
  end
end
