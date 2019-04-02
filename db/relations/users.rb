# frozen_string_literal: true

require 'bcrypt'

# Sanchin Power Users relation.
class Users < ROM::Relation[:sql]
  schema do
    attribute :id, CustomTypes::UUID
    attribute :created_at, Types::DateTime
    attribute :updated_at, Types::DateTime
    attribute :login, Types::String.optional.constrained(min_size: 3)
    attribute :password, CustomTypes::BCryptHash.optional
    attribute :firstname, Types::String.constrained(min_size: 1)
    attribute :lastname, Types::String.constrained(min_size: 1)
    attribute :birthday, Types::Date
    attribute :gender, CustomTypes::Gender.optional
  end
end
