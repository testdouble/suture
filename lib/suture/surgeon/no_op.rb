module Suture::Surgeon
  class NoOp
    def operate(plan)
      return unless plan.old
      plan.old.call(*plan.args)
    end
  end
end
