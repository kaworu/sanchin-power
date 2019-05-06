# frozen_string_literal: true

require_relative 'system/container'

# tasks we want in all env
load 'tasks/bcrypt.rake'
load 'tasks/sequel.rake'
load 'tasks/random.rake'

# development related tasks
Sanchin::Container.environment :development do
  load 'tasks/bundle_audit.rake'
  load 'tasks/reek.rake'
  load 'tasks/rerun.rake'
  load 'tasks/rubocop.rake'
  # default development task
  task default: 'rerun'
end

# test related tasks
Sanchin::Container.environment :test do
  load 'tasks/rspec.rake'
  # default test task
  task default: %w[db:reset spec]
end
