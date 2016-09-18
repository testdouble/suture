module Suture::Value
  class Plan
    attr_reader :name, :old, :new, :args, :after_new, :after_old, :on_new_error,
                :on_old_error, :database_path, :record_calls, :comparator,
                :call_both, :raise_on_result_mismatch,
                :return_old_on_result_mismatch, :fallback_on_error,
                :expected_error_types, :disable, :dup_args

    def initialize(attrs = {})
      @name = attrs[:name]
      @old = attrs[:old]
      @new = attrs[:new]
      @args = attrs[:args]
      @after_new = attrs[:after_new]
      @after_old = attrs[:after_old]
      @on_new_error = attrs[:on_new_error]
      @on_old_error = attrs[:on_old_error]
      @database_path = attrs[:database_path]
      @record_calls = !!attrs[:record_calls]
      @comparator = attrs[:comparator]
      @call_both = !!attrs[:call_both]
      @raise_on_result_mismatch = !!attrs[:raise_on_result_mismatch]
      @return_old_on_result_mismatch = !!attrs[:return_old_on_result_mismatch]
      @fallback_on_error = !!attrs[:fallback_on_error]
      @expected_error_types = attrs[:expected_error_types] || []
      @disable = !!attrs[:disable]
      @dup_args = !!attrs[:dup_args]
    end
  end
end
