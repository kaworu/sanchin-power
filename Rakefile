# frozen_string_literal: true

# load the Sanchin Power Application.
require_relative 'app/app'
app = Sanchin::App.new(root: Rake.original_dir)

# tasks we want in all env
# bcrypt cost
load 'tasks/bcrypt.rake'
# db stuff
require 'rom/sql/rake_task'
namespace :db do
  task :setup do
    ROM::SQL::RakeSupport.env = app.rom
  end
end

# development related tasks
app.configure :development do
  # reek
  require 'reek/rake/task'
  Reek::Rake::Task.new do |task|
    task.fail_on_error = false
  end
  # rubocop
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new do |task|
    task.fail_on_error = false
  end
  # default development task
  task :default do
    Rake::Task['rubocop'].invoke
    Rake::Task['reek'].invoke
  end
end

# test related tasks
app.configure :test do
  # rspec
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  # default test task
  task :default do
    Rake::Task['spec'].invoke
  end
end
