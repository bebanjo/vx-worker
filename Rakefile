require 'rubygems'
require 'bundler'
Bundler.require
require 'rspec/core/rake_task'
require "bundler/gem_tasks"

RSpec::Core::RakeTask.new(:spec)

desc "download test repo and run spec"
task :default => [:spec]

desc "run travis build"
task :travis do
  exec "bundle exec rake SPEC_OPTS='-t ~docker --order=rand'"
end
