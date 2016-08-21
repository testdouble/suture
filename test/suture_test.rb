require "suture/value/test_plan"
require "suture/value/test_results"

class SutureTest < Minitest::Test
  def test_create
    builds_plan = gimme_next(Suture::BuildsPlan)
    chooses_surgeon = gimme_next(Suture::ChoosesSurgeon)
    performs_surgery = gimme_next(Suture::PerformsSurgery)
    options = {:foo => :bar}
    plan = Suture::Value::Plan.new
    surgeon = Suture::Surgeon::NoOp.new
    give(builds_plan).build(:thing, options) { plan }
    give(chooses_surgeon).choose(plan) { surgeon }
    give(performs_surgery).perform(plan, surgeon) { :pants }

    result = Suture.create(:thing, options)

    assert_equal :pants, result
  end

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

    verify(interprets_results).interpret(test_results)
  end
end
