# frozen_string_literal: true

# load ENV.
require_relative 'app/env'
Sanchin::Env.load

# tasks we want in all env
load 'tasks/bcrypt.rake'
load 'tasks/rom.rake'

# development related tasks
Sanchin::Env.configure :development do
  load 'tasks/bundle_audit.rake'
  load 'tasks/reek.rake'
  load 'tasks/rerun.rake'
  load 'tasks/rubocop.rake'
  # default development task
  task default: 'rerun'
end

# test related tasks
Sanchin::Env.configure :test do
  load 'tasks/rspec.rake'
  # default test task
  task default: 'spec'
end
