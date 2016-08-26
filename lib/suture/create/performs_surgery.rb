module Suture
  class PerformsSurgery
    def perform(plan, surgeon)
      surgeon.operate(plan)
    end
  end
end
