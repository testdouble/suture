require "suture/util/scalpel"

module Suture::Surgeon
  class NoOp
    def operate(plan)
      if (code_path = code_path_for(plan))
        Suture::Util::Scalpel.new.cut(plan, code_path)
      end
    end

    private

    def code_path_for(plan)
      if plan.new && !plan.disable
        :new
      elsif plan.old
        :old
      end
    end
  end
end
