require "suture/tests_patient"
require "suture/value/observation"
require "suture/value/test_plan"

module Suture
  class TestsPatientTest < Minitest::Test
    def setup
      @subject = TestsPatient.new
    end

    def test_single_successful_call
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      observation = Value::Observation.new(1, :multiply, [1,2,3], 6)
      give(dictaphone).play(:multiply) { [observation] }
      test_plan = Value::TestPlan.new(
        :name => :multiply,
        :subject => lambda {|a,b,c| a * b * c }
      )

      result = @subject.test(test_plan)

      verify!(dictaphone).initialize(test_plan)
      assert_equal false, result.failed?
      assert_equal true, result.ran_all_tests?
      assert_equal 1, result.total_count
      assert_equal 1, result.passed_count
      assert_equal 0, result.failed_count
      assert_equal 0, result.skipped_count
      assert_equal observation, result.results.first[:observation]
      assert_equal true, result.results.first[:passed]
      assert_equal true, result.results.first[:ran]
    end

    def test_single_failing_call
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      observation = Value::Observation.new(1, :multiply, [1,2,3], "this isn't 6 at all!!!")
      give(dictaphone).play(:multiply) { [observation] }
      test_plan = Value::TestPlan.new(
        :name => :multiply,
        :subject => lambda {|a,b,c| a * b * c }
      )

      result = @subject.test(test_plan)

      verify!(dictaphone).initialize(test_plan)
      assert_equal true, result.failed?
      assert_equal true, result.ran_all_tests?
      assert_equal 1, result.total_count
      assert_equal 0, result.passed_count
      assert_equal 1, result.failed_count
      assert_equal 0, result.skipped_count
      assert_equal observation, result.results.first[:observation]
      assert_equal false, result.results.first[:passed]
      assert_equal true, result.results.first[:ran]
    end

    def test_fail_fast
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      call1 = Value::Observation.new(1, :multiply, [1,2,3], "this isn't 6 at all!!!")
      call2 = Value::Observation.new(1, :multiply, [1,2,3], 6)
      give(dictaphone).play(:multiply) { [call1, call2] }
      test_plan = Value::TestPlan.new(
        :name => :multiply,
        :subject => lambda {|a,b,c| a * b * c },
        :fail_fast => true
      )

      result = @subject.test(test_plan)

      verify!(dictaphone).initialize(test_plan)
      assert_equal true, result.failed?
      assert_equal false, result.ran_all_tests?
      assert_equal 2, result.total_count
      assert_equal 0, result.passed_count
      assert_equal 1, result.failed_count
      assert_equal 1, result.skipped_count
      assert_equal call1, result.results.first[:observation]
      assert_equal false, result.results.first[:passed]
      assert_equal true, result.results.first[:ran]
      assert_equal call2, result.results.last[:observation]
      assert_equal nil, result.results.last[:passed]
      assert_equal false, result.results.last[:ran]
    end
  end
end
