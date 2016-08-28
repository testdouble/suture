require "suture/util/scalpel"

module Suture::Surgeon
  class NoOp
    def operate(plan)
      return unless plan.old
      Suture::Util::Scalpel.new.cut(plan, :old)
    end
  end
end
