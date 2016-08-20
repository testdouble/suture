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
  end
end
