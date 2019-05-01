# frozen_string_literal: true

# Set the bcrypt cost to be used on this machine and register the :password
# dependency.
module Sanchin
  Container.boot(:password) do |container|
    init do
      require 'bcrypt'
    end

    start do
      use :environment
      BCrypt::Engine.cost = ENV['BCRYPT_COST'].to_i
      container.register(:password, BCrypt::Password)
    end
  end
end
