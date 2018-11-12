require "suture/error/verification_failed"

module Suture
  class InterpretsResults
    def interpret(test_plan, test_results)
      return unless test_results.failed?
      raise Suture::Error::VerificationFailed.new(test_plan, test_results)
    end
  end
end
