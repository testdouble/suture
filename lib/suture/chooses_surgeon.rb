module Suture
  class ChoosesSurgeon
    def choose(plan)
      if plan.record_calls
        Surgeon::Observer.new
      else
        Surgeon::NoOp.new
      end
    end
  end
end
