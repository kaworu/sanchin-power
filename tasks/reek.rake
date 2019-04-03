# frozen_string_literal: true

# See https://github.com/troessner/reek/blob/master/docs/Rake-Task.md

require 'reek/rake/task'

Reek::Rake::Task.new do |task|
  task.config_file   = File.join(Rake.original_dir, '.reek.yml')
  task.source_files  = FileList['**/*.rb'].exclude('vendor/**/*.rb')
  task.fail_on_error = false
end
