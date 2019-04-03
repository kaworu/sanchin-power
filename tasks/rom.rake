# frozen_string_literal: true

# Ruby Object Manager Rake stuff.
#
# See https://rom-rb.org/4.0/learn/sql/migrations/

require 'rom/sql/rake_task'

namespace :db do
  task :setup do
    require 'rom'
    config = ROM::Configuration.new(:sql, ENV['DATABASE_URL'])
    ROM::SQL::RakeSupport.env = ROM.container(config)
  end
end
