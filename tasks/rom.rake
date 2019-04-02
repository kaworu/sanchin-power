# frozen_string_literal: true

# Ruby Object Manager Rake stuff.
#
# See https://rom-rb.org/4.0/learn/sql/migrations/

require 'rom/sql/rake_task'

namespace :db do
  task :setup do
    # load the Sanchin Power Application.
    require_relative '../app/app'
    app = Sanchin::App.new(root: Rake.original_dir)
    ROM::SQL::RakeSupport.env = app.repositories.rom
  end
end
