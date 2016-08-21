require "suture/wrap/logger"
require "suture/util/env"

module Suture::Adapter
  module Log
    def self.logger
      if !@setup
        @logger = Suture::Wrap::Logger.init(Suture.config.merge(Suture::Util::Env.to_map))
        @setup = true
      end
      @logger
    end

    def self.reset!
      @setup = nil
      @logger = nil
    end

    def log_debug(*args, &blk)
      Log.logger.debug(*args, &blk)
    end

    def log_info(*args, &blk)
      Log.logger.info(*args, &blk)
    end

    def log_warn(*args, &blk)
      Log.logger.warn(*args, &blk)
    end
  end
end
