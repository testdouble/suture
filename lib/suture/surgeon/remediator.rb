require "suture/util/scalpel"

module Suture::Surgeon
  class Remediator
    include Suture::Adapter::Log

    def initialize
      @scalpel = Suture::Util::Scalpel.new
    end

    def operate(plan)
      begin
        new_result = @scalpel.cut(plan, :new)
        if plan.fallback_on_mismatch
          old_result = @scalpel.cut(plan, :old)
          fallback_on_mismatch(plan, old_result, new_result)
        else
          new_result
        end
      rescue StandardError => actual_error
        if plan.expected_error_types.any? { |e| actual_error.is_a?(e) }
          raise actual_error
        else
          @scalpel.cut(plan, :old)
        end
      end
    end

    def fallback_on_mismatch(plan, old_result, new_result)
      if plan.comparator.call(old_result, new_result)
        new_result
      else
        log_warn <<-MSG.gsub(/^ {10}/,'')
          Seam #{plan.name.inspect} is set to :fallback_on_mismatch,
          and they did not match. The new result was: ```
            #{new_result.inspect}
          ```
          The old result was: ```
            #{old_result.inspect}
          ```
        MSG
        old_result
      end
    end
  end
end
