# frozen_string_literal: true

require 'rom-repository'

module UserConcept
  # User repository.
  class Repository < ROM::Repository[:users]
    struct_namespace UserConcept

    # Find a user by its id.
    def find(id)
      users.by_pk(id).one!
    end
  end
end
