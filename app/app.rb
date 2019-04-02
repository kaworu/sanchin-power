# frozen_string_literal: true

require_relative 'config'
require_relative '../lib/repositories'

module Sanchin
  # The Sanchin Power Application.
  class App
    attr_reader :root, :config, :repositories

    # Load a new app given the project's root path.
    def initialize(root:)
      @root = root
      @config = Config.new(root: @root)
      @repositories = Repositories.new(@config)
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
