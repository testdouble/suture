require "suture/interprets_results"

module Suture
  class InterpretsResultsTest < Minitest::Test
    def setup
      @subject = InterpretsResults.new
    end

    def test_success_is_a_no_op
      test_results = Value::TestResults.new([])

      result = @subject.interpret(Value::TestPlan.new, test_results)

      assert_equal nil, result
    end

    def test_fail_and_all_ran
      test_results = Value::TestResults.new([{:passed => false, :ran => true}])

      expected_error = assert_raises(Suture::Error::VerificationFailed) {
        @subject.interpret(Value::TestPlan.new, test_results)
      }
    end
  end
end
