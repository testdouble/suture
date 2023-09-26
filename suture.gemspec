# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "suture/version"

Gem::Specification.new do |spec|
  spec.name = "suture"
  spec.version = Suture::VERSION
  spec.authors = ["Justin Searls"]
  spec.email = ["searls@gmail.com"]

  spec.summary = "A gem that helps people refactor or reimplement legacy code"
  spec.description = "Provides tools to record calls to legacy code and verify new implementations still work"
  spec.homepage = "https://github.com/testdouble/suture"

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(example|test|db|log|safe|spec|features)/}) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sqlite3"
  spec.add_dependency "backports"
  spec.add_dependency "bar-of-progress", ">= 0.1.3"
end
