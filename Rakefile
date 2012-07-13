#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'cucumber'
require 'cucumber/rake/task'

task :default => [:install, :features]

Cucumber::Rake::Task.new(:features) do |t|
  # t.cucumber_opts = ["features --format pretty -x"]

  t.cucumber_opts = ['--format', 'progress']
  t.cucumber_opts += ['features']
    
  # This turns on the GLI debugging backtraces
  t.cucumber_opts += ['GLI_DEBUG=true']
end

# https://github.com/troessner/reek/wiki
require 'reek/rake/task'
Reek::Rake::Task.new do |t|
  t.fail_on_error = false
  t.source_files = ['bin/*', 'lib/**/*.rb']
end

# https://github.com/turboladen/tailor
require 'tailor/rake_task'
Tailor::RakeTask.new do |task|
  task.file_set('lib/**/*.rb', 'code') do |style|
    style.max_line_length 100, level: :warn
    style.max_code_lines_in_method 50, level: :warn
  end
  task.file_set('bin/*', 'binaries') do |style|
    style.max_line_length 100, level: :warn
  end
end

# desc "Run tests, alias to `rake features`"
# task :test => [:features, :style]

# File lib/tasks/notes.rake
task :notes do
  puts `grep --exclude=Rakefile -r 'OPTIMIZE:\\|FIXME:\\|TODO:' .`
end