# frozen_string_literal: true

require 'dry-types'
require 'dry-validation'

module Sanchin
  # "extend" Dry::Types with our own custom types.
  # see https://dry-rb.org/gems/dry-types/including-types/
  module Types
    include Dry::Types.module

    Stripped = String.constructor do |str|
      str.strip.chomp rescue str
    end

    StrippedCapitalized = Stripped.constructor do |str|
      str.capitalize rescue str
    end

    StrippedDowncased = Stripped.constructor do |str|
      str.downcase rescue str
    end
  end
end
