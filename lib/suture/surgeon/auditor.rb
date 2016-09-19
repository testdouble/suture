require "suture/error/result_mismatch"
require "suture/value/result"
require "suture/util/compares_results"
require "suture/util/scalpel"

module Suture::Surgeon
  class Auditor
    include Suture::Adapter::Log

    def initialize
      @scalpel = Suture::Util::Scalpel.new
    end

    def operate(plan)
      new_result = result_for(plan, :new)
      old_result = result_for(plan, :old)
      if !comparable?(plan, old_result, new_result)
        handle_mismatch(plan, old_result, new_result)
      else
        return_result(new_result)
      end
    end

    private

    def result_for(plan, path)
      begin
        Suture::Value::Result.returned(@scalpel.cut(plan, path))
      rescue StandardError => error
        Suture::Value::Result.errored(error)
      end
    end

    def comparable?(plan, old_result, new_result)
      Suture::Util::ComparesResults.new(plan.comparator).compare(
        old_result,
        new_result
      )
    end

    def handle_mismatch(plan, old_result, new_result)
      log_warning(plan, old_result, new_result)
      if plan.raise_on_result_mismatch
        raise Suture::Error::ResultMismatch.new(plan, new_result, old_result)
      elsif plan.return_old_on_result_mismatch
        return_result(old_result)
      else
        return_result(new_result)
      end
    end

    def return_result(result)
      if result.errored?
        raise result.value
      else
        return result.value
      end
    end

    def log_warning(plan, old_result, new_result)
      log_warn <<-MSG.gsub(/^ {8}/,'')
        Seam #{plan.name.inspect} is set to :call_both the :new and :old code
        paths, but they did not match.

        The new result #{new_result.errored? ? "raised" : "returned"}: ```
          #{new_result.value.inspect}
        ```

        The old result #{old_result.errored? ? "raised" : "returned"}: ```
          #{old_result.value.inspect}
        ```
      MSG
    end
  end
end
