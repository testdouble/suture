require "suture/util/timer"

module Suture::Util
  class TimerTest < UnitTest
    def test_timer_is_not_immediately_up
      subject = Timer.new(0.001)

      assert_equal false, subject.time_up?
    end

    def test_timer_is_totally_up
      subject = Timer.new(0.001)

      sleep 0.002

      assert_equal true, subject.time_up?
    end
  end
end
