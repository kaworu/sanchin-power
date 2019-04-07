# frozen_string_literal: true

require 'rom-repository'
require_relative 'changesets/create'

module UserConcept
  # User repository.
  class Repository < ROM::Repository[:users]
    struct_namespace UserConcept

    # A user creation changeset.
    def create(payload)
      users.changeset(Changeset::Create, payload)
    end

    # Find a user by its id.
    def find(id)
      users.by_pk(id).one!
    end
  end
end
