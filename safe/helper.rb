require "minitest/autorun"
require "pry"

require "suture"

require "fileutils"
class SafeTest < Minitest::Test
  def setup
    super
    clean("db")
    ENV.delete_if { |(k,v)| k.start_with?("SUTURE_") }
  end

private

  def clean(p)
    FileUtils.rm_rf(path(p))
  rescue Errno::ENOENT
  end

  def path(p)
    File.join(Dir.getwd, p)
  end
end

