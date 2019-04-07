# frozen_string_literal: true

require 'representable/json'

module UserConcept
  # User presentation logic.
  class Presenter < Representable::Decorator
    include Representable::JSON

    property :id
    property :created_at
    property :updated_at
    property :login
    # NOTE: hide the password property
    property :firstname
    property :lastname
    property :birthday
    property :gender
  end
end
