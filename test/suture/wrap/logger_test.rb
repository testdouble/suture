require "suture/wrap/logger"

module Suture::Wrap
  class LoggerTest < UnitTest
    def teardown
      super
      ::Suture.reset!
      FileUtils.rm "log/suture-test.log"
    end

    def log_content
      IO.read("log/suture-test.log")
    end

    def test_default_logs_to_info
      logger = Logger.init(:log_file => "log/suture-test.log")

      logger.info "an info message"

      assert_match /Suture: an info message/, log_content
    end

    def test_logs_to_debug_level
      logger = Logger.init(
        :log_file => "log/suture-test.log",
        :log_level => "WARN"
      )

      logger.warn "an warn message"

      assert_match /Suture: an warn message/, log_content
    end

    def test_logs_to_stdout
      logger = Logger.init(
        :log_file => "log/suture-test.log",
        :log_stdout => "true"
      )

      out, _err = capture_subprocess_io do
        logger.warn "an message to stdout"
      end

      assert_match /Suture: an message to stdout/, out
    end
  end
end
