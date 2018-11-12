require "suture/verify/prescribes_test_plan"
require "suture/verify/tests_patient"
require "suture/verify/interprets_results"

module Suture
  def self.verify(name, options)
    test_plan = Suture::PrescribesTestPlan.new.prescribe(name, options)
    test_results = Suture::TestsPatient.new.test(test_plan)
    if test_results.failed?
      Suture::InterpretsResults.new.interpret(test_plan, test_results)
    end
  end
end
