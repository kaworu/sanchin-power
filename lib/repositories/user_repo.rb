# frozen_string_literal: true

require 'rom-repository'
require_relative '../../db/changesets/users/create_user'
require_relative '../errors/schema_error'
require_relative '../validators/users'

# User repository.
class UserRepo < ROM::Repository[:users]
  struct_namespace ::Sanchin::Entities
  include ::Validators::Users

  # Find a user by its id.
  def find(id)
    users.by_pk(id).one!
  end

  # Create a new user.
  def create(payload)
    change = users.changeset(CreateUserChangeset, payload)
    res = CreateSchema.call(change)
    raise SchemaError.new(errors: res.errors) unless res.success?

    change.commit
  end
end
