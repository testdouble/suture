module Suture::Value
  class Plan
    attr_reader :name, :old, :new, :args, :record_calls
    def initialize(attrs = {})
      @name = attrs[:name]
      @old = attrs[:old]
      @new = attrs[:new]
      @args = attrs[:args]
      @record_calls = !!attrs[:record_calls]
    end
  end
end
