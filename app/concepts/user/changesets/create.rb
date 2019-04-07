# frozen_string_literal: true

require 'rom-changeset'

module UserConcept
  module Changeset
    # User creation Changeset.
    #
    # Allow only a subset of the user schema. Other attributes (e.g. login,
    # password etc.) must be defined through others changesets.
    class Create < ROM::Changeset::Create
      map do
        symbolize_keys
        accept_keys %i[firstname lastname birthdate gender]
        map_value :birthdate, ->(val) { Date.parse(val)   rescue val }
        map_value :gender,    ->(val) { val.to_s.downcase rescue val }
      end
    end
  end
end
