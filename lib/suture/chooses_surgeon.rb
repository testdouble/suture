module Suture
  class ChoosesSurgeon
    def choose(plan)
      Surgeon::NoOp.new
    end
  end
end
