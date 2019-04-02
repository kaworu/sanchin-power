# frozen_string_literal: true

# Extend ROM SQL to add some custom types.
module ROM
  module SQL
    module CustomTypes
      UUID = Types::String.constrained(format: /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i)
      BCryptHash = Types::String.constrained(format: /^\$2[ayb]\$.{56}$/i)
      Gender = Types::String.enum('female', 'male')
    end
  end
end
