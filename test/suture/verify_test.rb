require "suture/verify"

module Suture
  class VerifyTest < UnitTest
    def test_verify_did_not_fail
      options = {:biz => :baz}
      test_plan = Suture::Value::TestPlan.new
      test_results = Suture::Value::TestResults.new([])
      prescribes_test_plan = gimme_next(Suture::PrescribesTestPlan)
      tests_patient = gimme_next(Suture::TestsPatient)
      give(prescribes_test_plan).prescribe(:stuff, options) { test_plan }
      give(tests_patient).test(test_plan) { test_results }

      Suture.verify(:stuff, options)
    end

    def test_verify_did_fail
      options = {:biz => :baz}
      test_plan = Suture::Value::TestPlan.new
      test_results = Suture::Value::TestResults.new([{:passed => false}])
      prescribes_test_plan = gimme_next(Suture::PrescribesTestPlan)
      tests_patient = gimme_next(Suture::TestsPatient)
      interprets_results = gimme_next(Suture::InterpretsResults)
      give(prescribes_test_plan).prescribe(:stuff, options) { test_plan }
      give(tests_patient).test(test_plan) { test_results }

      Suture.verify(:stuff, options)

      verify(interprets_results).interpret(test_plan, test_results)
    end
  end
end
