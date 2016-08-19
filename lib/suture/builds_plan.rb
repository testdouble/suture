module Suture
  class BuildsPlan
    def build(options)
      Value::Plan.new(options)
    end
  end
end
