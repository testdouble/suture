#!/usr/bin/env sh
export BUNDLE_GEMFILE="$PWD/Gemfile"
bundle install
bundle exec rake db:migrate
bundle exec rake db:test:prepare

