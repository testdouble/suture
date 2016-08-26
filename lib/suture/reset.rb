require "suture/adapter/log"

module Suture
  def self.reset!
    @config = nil #<-- TODO add an override mode to the config
    Adapter::Log.reset!
  end
end

