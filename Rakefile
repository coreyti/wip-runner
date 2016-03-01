require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

namespace :spec do
  desc 'Execute documentation Markdown specs'
  task :docs do |t|
    # Specdown considers any/all ARGV entries as paths to markdown files.
    # So, we reject the "spec:docs" arg which exists when running this task.
    ARGV.reject! { |arg| arg == t.name }

    require 'specdown'
    STDOUT.sync = true
    Specdown::Config.root = File.expand_path('../doc', __FILE__)
    # Specdown::Command.new.execute
    Specdown::Command.new.execute_with_hooks
  end
end
