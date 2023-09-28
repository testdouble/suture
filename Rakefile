require "bundler/gem_tasks"
require "rake/testtask"
require "tldr/rake"

TLDR::Task.new(:name => :unit)
TLDR::Task.new(:name => :safe, :config => TLDR::Config.new(
  :parallel => false,
  :load_paths => ["safe", "lib"],
  :helper => "safe/helper.rb",
  :paths => FileList["safe/**/*_test.rb"]
))

task :test => [:unit, :safe]

require "standard/rake"
task :default => [:test, :"standard:fix"]
