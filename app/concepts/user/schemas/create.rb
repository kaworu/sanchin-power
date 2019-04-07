# frozen_string_literal: true

require 'dry-validation'

module UserConcept
  module Schema
    # User creation Schema.
    Create = Dry::Validation.Schema do
      required(:firstname) { filled? & str? & size?(1..255) }
      required(:lastname)  { filled? & str? & size?(1..255) }
      required(:birthdate) { filled? & date? & lt?(Date.today) }
      optional(:gender)    { filled? & included_in?(%w[female male]) }
    end
  end
end
