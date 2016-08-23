if Gem.ruby_version >= Gem::Version.new("1.9.3")
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

