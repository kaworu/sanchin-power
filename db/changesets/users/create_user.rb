# frozen_string_literal: true

# User creation Changeset.
#
# Allow only a subset of the user schema. Other attributes (e.g. login,
# password etc.) must be defined through other changeset.
class CreateUserChangeset < ROM::Changeset::Create
  map do
    symbolize_keys
    accept_keys %i[firstname lastname birthday gender]
    map_value :birthday, ->(v) { Date.parse(v) rescue v }
    map_value :gender,   ->(v) { v.to_s        rescue v }
  end
end
