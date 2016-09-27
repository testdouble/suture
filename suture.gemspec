# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'suture/version'

Gem::Specification.new do |spec|
  spec.name          = "suture"
  spec.version       = Suture::VERSION
  spec.authors       = ["Justin Searls"]
  spec.email         = ["searls@gmail.com"]

  spec.summary       = %q{A gem that helps people refactor or reimplement legacy code}
  spec.description   = %q{Provides tools to record calls to legacy code and verify new implementations still work}
  spec.homepage      = "https://github.com/testdouble/suture"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(example|test|db|log|safe|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  sqlite3 = if defined? JRUBY_VERSION
              "activerecord-jdbcsqlite3-adapter"
            else
              "sqlite3"
            end
  spec.add_dependency sqlite3
  spec.add_dependency "backports"
  spec.add_dependency "bar-of-progress", ">= 0.1.3"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.9.12.6"
  spec.add_development_dependency "minitest", "~> 5.9"
  spec.add_development_dependency "gimme", "~> 0.5"

  if Gem.ruby_version >= Gem::Version.new("1.9.3")
    spec.add_development_dependency "codeclimate-test-reporter"
    spec.add_development_dependency "simplecov", "~> 0.11.2" #<--only here to lock
  end

  if Gem.ruby_version >= Gem::Version.new("2.2.2")
    spec.add_development_dependency "github_changelog_generator"
  end
end
