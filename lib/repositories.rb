# frozen_string_literal: true

require 'rom'
require 'rom-sql'
require_relative 'entities'
require_relative 'repositories/user_repo'

module Sanchin
  # All the repositories of Sanchin Power.
  class Repositories
    attr_reader :rom
    attr_reader :users

    def initialize(config)
      # ROM setup.
      rconfig = ROM::Configuration.new(:sql, config.database_url)
      rconfig.auto_registration(config.rom_path, namespace: false)
      @rom = ROM.container(rconfig)
      setup
    end

    protected

    def setup
      @users = UserRepo.new(@rom)
    end
  end
end
