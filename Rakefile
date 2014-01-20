require 'rubygems'
require 'bundler'
Bundler.require
require 'rspec/core/rake_task'
require "bundler/gem_tasks"

RSpec::Core::RakeTask.new(:spec)

desc "download test repo and run spec"
task :default => ["test:create_repo", :spec]

namespace :test do
  desc "download test repo"
  task :create_repo do
    dir = "fixtures/repo"
    unless File.directory? dir
      cmd = "git clone https://github.com/dima-exe/ci-worker-test-repo.git fixtures/repo"
      puts cmd
      system cmd
    end
  end
end

desc "run travis build"
task :travis do
  exec "bundle exec rake SPEC_OPTS='--format documentation -t ~docker --order=rand'"
end

desc "build package"
task :package do
  exec "dist/build.sh"
end

