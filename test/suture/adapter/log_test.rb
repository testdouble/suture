require "suture/adapter/log"

module Suture::Adapter
  class LogTest < UnitTest
    dont_run_these_in_parallel!

    class FakeThing
      include Suture::Adapter::Log

      def stuff
        log_debug("an debug")
        log_info("an info")
        log_warn("an warn")
        log_error("an error")
      end
    end

    def setup
      super
      @log_io = StringIO.new
      config_log(:log_io => @log_io)
    end

    def test_debug_level
      config_log(:log_level => "DEBUG")

      FakeThing.new.stuff

      assert_match "Suture: an debug", read_log
      assert_match "Suture: an info", read_log
      assert_match "Suture: an warn", read_log
      assert_match "Suture: an error", read_log
    end

    def test_warn_level
      config_log(:log_level => "WARN")

      FakeThing.new.stuff

      assert_not_match "Suture: an debug", read_log
      assert_not_match "Suture: an info", read_log
      assert_match "Suture: an warn", read_log
      assert_match "Suture: an error", read_log
    end

    def test_error_level
      config_log(:log_level => "ERROR", :log_file => nil)

      FakeThing.new.stuff

      assert_not_match "Suture: an debug", read_log
      assert_not_match "Suture: an info", read_log
      assert_not_match "Suture: an warn", read_log
      assert_match "Suture: an error", read_log
    end

    def test_default_level
      config_log(:log_level => nil)

      FakeThing.new.stuff

      assert_not_match "Suture: an debug", read_log
      assert_match "Suture: an info", read_log
      assert_match "Suture: an warn", read_log
      assert_match "Suture: an error", read_log
    end

    private

    def config_log(attrs)
      Suture.config(attrs)
      Suture::Adapter::Log.reset!
    end

    def read_log
      @log_io.tap(&:rewind).read
    end
  end
end
