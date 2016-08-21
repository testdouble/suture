require "suture/error/verification_failed"

module Suture
  class InterpretsResults
    def interpret(test_results)
      return unless test_results.failed?
    end
  end
end


