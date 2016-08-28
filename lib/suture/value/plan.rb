module Suture::Value
  class Plan
    attr_reader :name, :old, :new, :args,
                :after_new, :after_old,
                :database_path, :record_calls, :comparator,
                :call_both, :raise_on_result_mismatch,
                :call_old_on_error

    def initialize(attrs = {})
      @name = attrs[:name]
      @old = attrs[:old]
      @new = attrs[:new]
      @args = attrs[:args]
      @after_new = attrs[:after_new]
      @after_old = attrs[:after_old]
      @database_path = attrs[:database_path]
      @record_calls = !!attrs[:record_calls]
      @comparator = attrs[:comparator]
      @call_both = !!attrs[:call_both]
      @raise_on_result_mismatch = !!attrs[:raise_on_result_mismatch]
      @call_old_on_error = !!attrs[:call_old_on_error]
    end
  end
end
