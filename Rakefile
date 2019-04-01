# frozen_string_literal: true

# load the Sanchin Power Application.
require_relative 'app/app'
app = Sanchin::App.new(root: Rake.original_dir)

# tasks we want in all env
load 'tasks/bcrypt.rake'
require 'rom/sql/rake_task'
namespace :db do
  task :setup do
    ROM::SQL::RakeSupport.env = app.rom
  end
end

app.configure :development do
  # development related tasks
  require 'reek/rake/task'
  require 'rubocop/rake_task'
  Reek::Rake::Task.new do |t|
    t.fail_on_error = false
  end
  RuboCop::RakeTask.new
  task :default do
    Rake::Task['rubocop'].invoke
    Rake::Task['reek'].invoke
  end
end

app.configure :test do
  # test related tasks
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default do
    Rake::Task['spec'].invoke
  end
end
