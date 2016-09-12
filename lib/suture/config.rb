require "suture/comparator"

module Suture
  DEFAULT_OPTIONS = {
    :database_path => "db/suture.sqlite3",
    :comparator => Comparator.new,
    :log_level => "INFO",
    :log_stdout => true,
    :log_io => nil,
    :log_file => nil,
    :raise_on_result_mismatch => false
  }

  def self.config(config = {})
    @config ||= DEFAULT_OPTIONS.dup
    @config.merge!(config)
  end

  def self.config_reset!
    @config = DEFAULT_OPTIONS.dup
  end
end
