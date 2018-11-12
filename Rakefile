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
    "safe/support/code_climate",
    "test/helper.rb",
    "test/**/*_test.rb",
    "safe/helper.rb",
    "safe/**/*_test.rb"
  ]
end

task :example do
  Dir.chdir("example/rails_app") do
    passed = system <<-SH
      BUNDLE_GEMFILE="$PWD/Gemfile" bundle install --quiet
      BUNDLE_GEMFILE="$PWD/Gemfile" bundle exec rake suture
    SH
    unless passed
      raise StandardError, "Rails example failed!"
    end
  end
end

if Gem.ruby_version >= Gem::Version.new("2.2.2")
  require "github_changelog_generator/task"
  GitHubChangelogGenerator::RakeTask.new :changelog
  task :changelog_commit do
    require "suture"
    cmd = "git commit -m \"Changelog for #{Suture::VERSION}\" -- CHANGELOG.md"
    puts "-------> #{cmd}"
    system cmd
  end
  Rake::Task["release:rubygem_push"].enhance([:changelog, :changelog_commit])
end

task :default => [:test, :example]
