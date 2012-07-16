#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'cucumber'
require 'cucumber/rake/task'

task :default => [:install, :test]

desc "Run tests"
task :test => [:features, :tailor]

Cucumber::Rake::Task.new(:features) do |t|
  # t.cucumber_opts = ['--format pretty -x']

  t.cucumber_opts = ['--format', 'progress', '-x']
  t.cucumber_opts += ['features']
    
  # This turns on the GLI debugging backtraces
  t.cucumber_opts += ['GLI_DEBUG=true']
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

require 'rdoc/task'
Rake::RDocTask.new do |rd|
  rd.main = "README.md"
  rd.rdoc_files.include("README.md","lib/**/*.rb","bin/**/*")
  rd.title = 'melai'
end

# File lib/tasks/notes.rake
desc "Find notes in code"
task :notes do
  puts `grep --exclude=Rakefile -r 'OPTIMIZE:\\|FIXME:\\|TODO:' .`
end
