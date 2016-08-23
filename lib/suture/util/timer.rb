require "time"

module Suture::Util
  class Timer
    def initialize(limit_in_seconds)
      @started_at = Time.new
      @limit_in_seconds = limit_in_seconds
    end

    def time_up?
      Time.new >= (@started_at + @limit_in_seconds)
    end
  end
end
