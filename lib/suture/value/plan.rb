module Suture::Value
  class Plan
    attr_reader :old, :args
    def initialize(attrs = {})
      @old = attrs[:old]
      @args = attrs[:args]
    end
  end
end
