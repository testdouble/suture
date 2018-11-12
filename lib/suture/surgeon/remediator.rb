require "suture/util/scalpel"

module Suture::Surgeon
  class Remediator
    def initialize
      @scalpel = Suture::Util::Scalpel.new
    end

    def operate(plan)
      @scalpel.cut(plan, :new)
    rescue => actual_error
      if plan.expected_error_types.any? { |e| actual_error.is_a?(e) }
        raise actual_error
      else
        @scalpel.cut(plan, :old)
      end
    end
  end
end
