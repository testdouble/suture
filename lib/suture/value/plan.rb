module Suture::Value
  class Plan
    attr_reader :name, :old, :new, :args,
                :database_path, :record_calls, :comparator,
                :call_both, :call_old_on_error

    def initialize(attrs = {})
      @name = attrs[:name]
      @old = attrs[:old]
      @new = attrs[:new]
      @args = attrs[:args]
      @database_path = attrs[:database_path]
      @record_calls = !!attrs[:record_calls]
      @comparator = attrs[:comparator]
      @call_both = !!attrs[:call_both]
      @call_old_on_error = !!attrs[:call_old_on_error]
    end
  end
end
