require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/helper.rb', 'test/**/*_test.rb']
end

Rake::TestTask.new(:safe) do |t|
  t.libs << "safe"
  t.libs << "lib"
  t.test_files = FileList['safe/helper.rb', 'safe/**/*_test.rb']
end

Rake::TestTask.new(:everything) do |t|
  t.libs << "test"
  t.libs << "safe"
  t.libs << "lib"
  t.test_files = FileList[
    'safe/support/code_climate',
    'test/helper.rb',
    'test/**/*_test.rb',
    'safe/helper.rb',
    'safe/**/*_test.rb'
  ]
end

require 'github_changelog_generator/task'

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.since_tag = '0.1.14'
  config.future_release = '0.2.0'
end
task :release => :changelog

task :default => :everything
