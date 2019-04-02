# frozen_string_literal: true

module ROM
  module SQL
    # Extend ROM SQL to add some custom types.
    module CustomTypes
      # UUIDv4 regexp.
      def self.uuid_re
        /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i
      end

      # Bcrypt Hash regexp.
      def self.bcrypthash_re
        /^\$2[ayb]\$.{56}$/i
      end

      # our custom types.
      UUID       = Types::String.constrained(format: uuid_re)
      BCryptHash = Types::String.constrained(format: bcrypthash_re)
      Gender     = Types::String.enum('female', 'male')
    end
  end
end
