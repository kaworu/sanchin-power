# frozen_string_literal: true

# See https://dry-rb.org/gems/dry-validation/0.13/extensions/monads/
module Sanchin
  Container.boot(:dry) do
    init do
      require 'dry-validation'
    end

    start do
      Dry::Validation.load_extensions(:monads)
    end
  end
end
