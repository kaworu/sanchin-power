# frozen_string_literal: true

module Sanchin
  # All the repositories of Sanchin Power.
  class Repositories
    attr_reader :users

    def initialize
      config = ROM::Configuration.new(:sql, ENV['DATABASE_URL'])
      config.register_relation(UserConcept::Relation)
      container = ROM.container(config)
      @users = UserConcept::Repository.new(container)
    end
  end
end
