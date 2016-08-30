module Suture::Value
  class Observation
    attr_reader :id, :name, :args, :result, :error
    def initialize(id, name, args, result, error = nil)
      @id = id
      @name = name
      @args = args
      @result = result
      @error = error
    end
  end
end
