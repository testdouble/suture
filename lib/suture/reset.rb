require "suture/adapter/log"

module Suture
  def self.reset!
    Suture.config_reset!
    Adapter::Log.reset!
  end
end
