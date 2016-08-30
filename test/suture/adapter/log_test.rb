require "suture/adapter/log"

module Suture::Adapter
  class LogTest < UnitTest
    class FakeThing
      include Suture::Adapter::Log

      def stuff
        log_debug("an debug")
        log_info("an info")
        log_warn("an warn")
      end
    end

    def teardown
      super
      Suture.reset!
    end

    def test_log_adapter_to_stdout
      Suture.config(:log_level => "DEBUG", :log_stdout => "true")

      subject = FakeThing.new

      out, _err = capture_subprocess_io do
        subject.stuff
      end

      assert_match /Suture: an debug/, out
      assert_match /Suture: an info/, out
      assert_match /Suture: an warn/, out
    end
  end
end
