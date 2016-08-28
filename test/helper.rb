require "minitest/autorun"
require "gimme"
require "pry"

require "suture"

require "support/assertions"

class UnitTest < Minitest::Test
  include Support::Assertions

  def setup
    super
    Suture.config(:log_stdout => false)
    Suture::Adapter::Log.reset!
  end
end

