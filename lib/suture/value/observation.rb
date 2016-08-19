module Suture::Value
  class Observation
    attr_reader :id, :name, :args, :result
    def initialize(id, name, args, result)
      @id = id
      @name = name
      @args = args
      @result = result
    end
  end
end
