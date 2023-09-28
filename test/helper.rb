require "gimme"
require "tldr"

require "suture/config"
require "support/assertions"
class UnitTest < TLDR
  include Support::Assertions
  include TLDR::Assertions::MinitestCompatibility

  def setup
    super
    Suture.config(:log_level => "DEBUG", :log_stdout => false, :log_file => "log/unit.log")
    Suture::Adapter::Log.reset!
  end
end
