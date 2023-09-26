require "minitest/autorun"
require "gimme"

require "suture/config"
require "support/assertions"
class UnitTest < Minitest::Test
  include Support::Assertions

  def setup
    super
    Suture.config(:log_level => "DEBUG", :log_stdout => false, :log_file => "log/unit.log")
    Suture::Adapter::Log.reset!
  end
end
