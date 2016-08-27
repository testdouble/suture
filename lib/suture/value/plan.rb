module Suture::Value
  class Plan
    attr_reader :name, :old, :new, :args,
                :record_calls, :comparator, :database_path

    def initialize(attrs = {})
      @name = attrs[:name]
      @old = attrs[:old]
      @new = attrs[:new]
      @args = attrs[:args]
      @record_calls = !!attrs[:record_calls]
      @comparator = attrs[:comparator]
      @database_path = attrs[:database_path]
    end
  end
end
