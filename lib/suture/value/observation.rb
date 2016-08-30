module Suture::Value
  class Observation
    attr_reader :id, :name, :args, :result, :error
    def initialize(attrs)
      @id = attrs[:id]
      @name = attrs[:name]
      @args = attrs[:args]
      @result = attrs[:result]
      @error = attrs[:error]
    end

    def expectation
      {
        :outcome => attrs[:error] || attrs[:result],
        :means => attrs[:error] ? :raised : :returned
      }
    end
  end
end
