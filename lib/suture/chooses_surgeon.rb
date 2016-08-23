require "suture/surgeon/observer"
require "suture/surgeon/no_op"

module Suture
  class ChoosesSurgeon
    def choose(plan)
      if plan.record_calls
        if plan.new
          log_warn <<-MSG
            Seam #{name.inspect} has a :new code path defined, but because it is
            set to :record_calls, we will invoke the :old code path instead. If
            this is not what you intend, set :record_calls to false.
          MSG
        Surgeon::Observer.new
      else
        Surgeon::NoOp.new
      end
    end
  end
end
