require "suture/comparator"

module Suture
  DEFAULT_OPTIONS = {
    :database_path => "db/suture.sqlite3",
    :comparator => Comparator.new,
    :log_level => "INFO",
    :log_file => nil,
    :log_stdout => true
  }

  def self.config(config = {})
    @config ||= DEFAULT_OPTIONS.dup
    @config.merge!(config)
  end
end
