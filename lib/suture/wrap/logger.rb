require "logger"

module Suture::Wrap
  module Logger
    def self.init(options)
      @logger = if options[:log_file]
        full_path = File.join(Dir.getwd, options[:log_file])
        FileUtils.mkdir_p(File.dirname(full_path))
        ::Logger.new(full_path)
      else
        ::Logger.new(NullIO.new)
      end

      @logger.level = if options[:log_level]
                        ::Logger.const_get(options[:log_level])
                      else
                        ::Logger::INFO
                      end

      @logger.formatter = proc { |_, time , _, msg|
        formatted_time = time.strftime("%Y-%m-%dT%H:%M:%S.%6N")
        "[#{formatted_time}] Suture: #{msg}\n".tap { |out|
          puts out if options[:log_stdout]
          options[:log_io].write(out) if options[:log_io]
        }
      }

      return @logger
    end

    class NullIO
      def gets; end
      def each; end
      def read(count=nil,buffer=nil); (count && count > 0) ? nil : ""; end
      def rewind; 0; end
      def close; end
      def size; 0; end
      def sync=(*args); end
      def puts(*args); end
      def write(*args); end
    end
  end
end
