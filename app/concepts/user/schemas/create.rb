# frozen_string_literal: true

require 'dry-validation'

module UserConcept
  module Schemas
    # User creation Schema.
    CreateSchema = Dry::Validation.Schema do
      required(:firstname) { filled? & str? & size?(1..255) }
      required(:lastname)  { filled? & str? & size?(1..255) }
      required(:birthday)  { filled? & date? & lt?(Date.today) }
      optional(:gender)    { filled? & included_in?(%w[female male]) }
    end
  end
end
