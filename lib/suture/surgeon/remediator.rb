require "suture/util/scalpel"

module Suture::Surgeon
  class Remediator
    def initialize
      @scalpel = Suture::Util::Scalpel.new
    end

    def operate(plan)
      old_result = nil
      begin
        new_result = @scalpel.cut(plan ,:new)
        if plan.raise_on_result_mismatch
          old_result ||= @scalpel.cut(plan, :old)
          if !plan.comparator.call(old_result, new_result)
            raise Suture::Error::ResultMismatch.new(plan, new_result, old_result)
          end
        end
        new_result
      rescue StandardError => actual_error
        if plan.expected_error_types.any? { |e| actual_error.is_a?(e) }
          raise actual_error
        else
          old_result || @scalpel.cut(plan, :old)
        end
      end
    end
  end
end
