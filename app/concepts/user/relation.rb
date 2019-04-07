# frozen_string_literal: true

require 'rom'
require 'rom-sql'
require_relative '../../../lib/regexp'

module UserConcept
  # Sanchin Power Users relation.
  class Relation < ROM::Relation[:sql]
    include ::Sanchin::Regexp

    schema :users do
      attribute :id, Types::String.constrained(format: UUID_V4).meta(primary_key: true)
      attribute :created_at, Types::DateTime
      attribute :updated_at, Types::DateTime
      attribute :login, Types::String.optional
      attribute :password, Types::String.constrained(format: BCRYPT_HASH)
      attribute :firstname, Types::String
      attribute :lastname, Types::String
      attribute :birthdate, Types::Date
      attribute :gender, Types::String.enum('female', 'male')
    end

    dataset do
      order { created_at.asc }
    end
  end
end
