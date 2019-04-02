# frozen_string_literal: true

# Error raised when a schema validation failed.
#
# See validators/
class SchemaError < StandardError
  attr_reader :errors

  # Create a new SchemaError given its errors and optional message.
  def initialize(errors:, msg: 'Schema violation')
    super(msg)
    @errors = errors
  end
end
