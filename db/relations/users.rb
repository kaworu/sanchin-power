# frozen_string_literal: true

require 'bcrypt'
require_relative '../custom_types'

# Sanchin Power Users relation.
class Users < ROM::Relation[:sql]
  schema do
    attribute :id, CustomTypes::UUID.meta(primary_key: true)
    attribute :created_at, Types::DateTime
    attribute :updated_at, Types::DateTime
    attribute :login, Types::String.optional
    attribute :password, CustomTypes::BCryptHash.optional
    attribute :firstname, Types::String
    attribute :lastname, Types::String
    attribute :birthday, Types::Date
    attribute :gender, CustomTypes::Gender.optional
  end

  dataset do
    order { created_at.asc }
  end
end
