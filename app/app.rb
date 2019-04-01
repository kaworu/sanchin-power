# frozen_string_literal: true
require 'rom'
require 'rom-sql'
require_relative 'config'

module Sanchin
  # The Sanchin Power Application.
  class App
    attr_reader :root, :config, :rom

    # Load a new app given the project's root path.
    def initialize(root:)
      @root    = root
      @config  = Config.new(root: @root)
      @rconfig = ROM::Configuration.new(:sql, config.database_url)
      @rconfig.auto_registration(config.rom_auto_registration_path)
      @rom = ROM.container(@rconfig)
    end

    # The loaded environment.
    def env
      config.env
    end

    # Yield if and only if the given target env is the current one.
    def configure(target)
      yield if env == target
    end
  end
end
