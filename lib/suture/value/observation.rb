require "suture/value/result"

module Suture::Value
  class Observation
    attr_reader :id, :name, :args

    def initialize(attrs)
      @id = attrs[:id]
      @name = attrs[:name]
      @args = attrs[:args]
      @return_value = attrs[:return]
      @error = attrs[:error]
    end

    def result
      @expectation ||= @error ? Result.errored(@error) : Result.returned(@return_value)
    end
  end
end
