# frozen_string_literal: true

# load the Sanchin Power Application.
require_relative 'app/app'
app = Sanchin::App.new(root: Rake.original_dir)

# tasks we want in all env
load 'tasks/bcrypt.rake'
load 'tasks/rom.rake'

# development related tasks
app.configure :development do
  load 'tasks/reek.rake'
  load 'tasks/rubocop.rake'
  load 'tasks/bundle_audit.rake'
  # default development task
  task :default do
    Rake::Task['rubocop'].invoke
    Rake::Task['reek'].invoke
  end
end

# test related tasks
app.configure :test do
  load 'tasks/rspec.rake'
  # default test task
  task :default do
    Rake::Task['spec'].invoke
  end
end
