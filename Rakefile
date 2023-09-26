require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:unit) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/helper.rb", "test/**/*_test.rb"]
end

Rake::TestTask.new(:safe) do |t|
  t.libs << "safe"
  t.libs << "lib"
  t.test_files = FileList["safe/helper.rb", "safe/**/*_test.rb"]
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "safe"
  t.libs << "lib"
  t.test_files = FileList[
    "test/helper.rb",
    "test/**/*_test.rb",
    "safe/helper.rb",
    "safe/**/*_test.rb"
  ]
end

require "standard/rake"
task :default => [:test, :"standard:fix"]
