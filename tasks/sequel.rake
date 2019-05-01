# frozen_string_literal: true

# Sequel migration rake setup.
namespace :db do
  task :connect do
    Sanchin::Container.start :database
    Sequel.extension :migration
    DB = Sanchin::Container['database']
  end

  # see https://github.com/jeremyevans/sequel/blob/master/doc/migration.rdoc#running-migrations-from-a-rake-task
  desc 'Run migrations'
  task migrate: [:connect] do |_, args|
    version = args[:version].to_i if args[:version]
    Sequel::Migrator.run(DB, 'db/migrations', target: version)
  end

  # inspired by https://gist.github.com/DevL/4266573
  desc 'Perform migration reset (full erase and migration up).'
  task reset: [:connect] do
    Sequel::Migrator.run(DB, 'db/migrations', target: 0)
    Sequel::Migrator.run(DB, 'db/migrations')
  end
end
