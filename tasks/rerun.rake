# frozen_string_literal: true

desc 'run the application server and watch for changes'
task :rerun do
  sh File.join(Rake.original_dir, 'bin', 'rerun')
end
