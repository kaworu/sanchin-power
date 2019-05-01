# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :user, class: Hash do
    firstname { Faker::Name.first_name }
    lastname  { Faker::Name.last_name }
    gender    { Faker::Gender.binary_type }
    birthdate { Faker::Date.birthday(5, 95) }

    initialize_with { attributes }
  end
end
