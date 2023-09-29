require "bundler/gem_tasks"
require "rake/testtask"
require "tldr/rake"

TLDR::Task.new(:name => :unit)

TLDR::Task.new(:name => :safe, :config => TLDR::Config.new(
  :parallel => false,
  :load_paths => ["safe", "lib"],
  :helper_paths => ["safe/helper.rb"],
  :paths => FileList["safe/**/*_test.rb"]
))

TLDR::Task.new(:name => :test, :config => TLDR::Config.new(
  :load_paths => ["safe", "test", "lib"],
  :helper_paths => ["test/helper.rb", "safe/helper.rb"],
  :paths => FileList["test/**/*_test.rb", "safe/**/*_test.rb"]
))

require "standard/rake"
task :default => [:test, :"standard:fix"]
