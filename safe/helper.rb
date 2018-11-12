require "minitest/autorun"
require "pry"

require "suture"

require "fileutils"
class SafeTest < Minitest::Test
  def setup
    super
    clean("db")
    ENV.delete_if { |(k, _)| k.start_with?("SUTURE_") }
    Suture.reset!
    Suture.config(:log_level => "DEBUG", :log_stdout => false, :log_file => "log/safe.log")
    Suture::Adapter::Log.reset!
  end

  private

  def clean(p)
    FileUtils.rm_rf(path(p))
  end

  def path(p)
    File.join(Dir.getwd, p)
  end
end
