require "logger"

module Suture::Wrap
  module Logger
    def self.init(options)
      if options[:log_file]
        full_path = File.join(Dir.getwd, options[:log_file])
        FileUtils.mkdir_p(File.dirname(full_path))
        @logger = ::Logger.new(full_path)
      elsif options[:log_stdout]
        @logger = ::Logger.new(STDOUT)
      else
        @logger = NullLogger.new
      end

      @logger.level = if options[:log_level]
        ::Logger.const_get(options[:log_level])
      else
        ::Logger::INFO
      end

      @logger.formatter = proc { |_, time , _, msg|
        formatted_time = time.strftime("%Y-%m-%dT%H:%M:%S.%6N")
        "[#{formatted_time}] Suture: #{msg.dump}\n".tap { |out|
          puts out if options[:log_file] && options[:log_stdout]
        }
      }

      return @logger
    end

    class NullLogger
      def formatter=; end
      def level=; end
      def debug; end
      def info; end
      def warn; end
    end
  end
end
