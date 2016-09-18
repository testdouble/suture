require "suture/error/result_mismatch"
require "suture/util/scalpel"

module Suture::Surgeon
  class Auditor
    include Suture::Adapter::Log

    def operate(plan)
      scalpel = Suture::Util::Scalpel.new
      new_result = scalpel.cut(plan, :new)
      old_result = scalpel.cut(plan, :old)
      if !plan.comparator.call(old_result, new_result)
        handle_mismatch(plan, old_result, new_result)
      else
        new_result
      end
    end

    private

    def handle_mismatch(plan, old_result, new_result)
      log_warning(plan, old_result, new_result)
      if plan.raise_on_result_mismatch
        raise Suture::Error::ResultMismatch.new(plan, new_result, old_result)
      elsif plan.return_old_on_result_mismatch
        old_result
      else
        new_result
      end
    end

    def log_warning(plan, old_result, new_result)
      log_warn <<-MSG.gsub(/^ {8}/,'')
        Seam #{plan.name.inspect} is set to :call_both the :new and :old code
        paths, but they did not match. The new result was: ```
          #{new_result.inspect}
        ```
        The old result was: ```
          #{old_result.inspect}
        ```
      MSG
    end
  end
end
