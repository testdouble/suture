require "suture/verify/tests_patient"
require "suture/verify/prescribes_test_plan"
require "suture/value/observation"

module Suture
  class TestsPatientTest < UnitTest
    def setup
      super
      @subject = TestsPatient.new
    end

    def test_single_successful_call
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      observation = Value::Observation.new(1, :multiply, [1,2,3], 6)
      test_plan = PrescribesTestPlan.new.prescribe(:multiply,
        :subject => lambda {|a,b,c| a * b * c },
        :verify_only => "1337"
      )
      give(dictaphone).play(1337) { [observation] }

      result = @subject.test(test_plan)

      verify!(dictaphone).initialize(test_plan)
      assert_equal false, result.failed?
      assert_equal true, result.ran_all_tests?
      assert_equal 1, result.total_count
      assert_equal 1, result.passed_count
      assert_equal 0, result.failed_count
      assert_equal 0, result.skipped_count
      assert_equal 0, result.errored_count
      assert_equal({
        :observation => observation,
        :new_result => 6,
        :passed => true,
        :ran => true
      }, result.results.first)
    end

    def test_single_failing_call
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      observation = Value::Observation.new(1, :multiply, [1,2,3], "this isn't 6 at all!!!")
      give(dictaphone).play(nil) { [observation] }
      test_plan = PrescribesTestPlan.new.prescribe(:multiply,
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
      assert_equal 0, result.errored_count
      assert_equal({
        :observation => observation,
        :passed => false,
        :new_result => 6,
        :ran => true
      }, result.results.first)
    end

    def test_fail_fast
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      call1 = Value::Observation.new(1, :multiply, [1,2,3], "this isn't 6 at all!!!")
      call2 = Value::Observation.new(1, :multiply, [1,2,3], 6)
      give(dictaphone).play(nil) { [call1, call2] }
      test_plan = PrescribesTestPlan.new.prescribe(:multiply,
        :subject => lambda {|a,b,c| a * b * c },
        :fail_fast => true,
        :random_seed => 48
      )

      result = @subject.test(test_plan)

      verify!(dictaphone).initialize(test_plan)
      assert_equal true, result.failed?
      assert_equal false, result.ran_all_tests?
      assert_equal 2, result.total_count
      assert_equal 0, result.passed_count
      assert_equal 1, result.failed_count
      assert_equal 1, result.skipped_count
      assert_equal 0, result.errored_count
      assert_equal({
        :observation => call1,
        :passed => false,
        :new_result => 6,
        :ran => true
      }, result.results.first)
      assert_equal({
        :observation => call2,
        :ran => false
      }, result.results.last)
    end

    def test_with_errors
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      some_error = StandardError.new
      call1 = Value::Observation.new(1, :multiply, [2,3,4], 24)
      call2 = Value::Observation.new(1, :multiply, [1,2,3], 6)
      give(dictaphone).play(nil) { [call1, call2] }
      test_plan = PrescribesTestPlan.new.prescribe(:multiply,
        :subject => lambda {|a,b,c|
          if a == 2
            raise some_error
          else
            a * b * c
          end
        },
        :fail_fast => false,
        :random_seed => 48 #<-- found this by trial and error ¯\_(ツ)_/¯
      )

      result = @subject.test(test_plan)

      verify!(dictaphone).initialize(test_plan)
      assert_equal true, result.failed?
      assert_equal true, result.ran_all_tests?
      assert_equal 2, result.total_count
      assert_equal 1, result.passed_count
      assert_equal 1, result.failed_count
      assert_equal 0, result.skipped_count
      assert_equal 1, result.errored_count
      assert_equal({
        :observation => call1,
        :passed => false,
        :error => some_error,
        :ran => true
      }, result.results.first)
      assert_equal({
        :observation => call2,
        :passed => true,
        :new_result => 6,
        :ran => true
      }, result.results.last)
    end

    def test_call_limit
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      give(dictaphone).play(nil) {[
        Value::Observation.new(1, :limit, [0], 1),
        Value::Observation.new(2, :limit, [1], 2),
        Value::Observation.new(3, :limit, [2], 3)
      ]}
      call_count = 0
      test_plan = PrescribesTestPlan.new.prescribe(:multiply,
        :subject => lambda {|n| call_count += 1; n + 1 },
        :call_limit => 2
      )

      result = @subject.test(test_plan)

      assert_equal 2, call_count
      assert_equal 2, result.passed_count
      assert_equal 1, result.skipped_count
    end

    def test_time_limit
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      timer = gimme_next(Suture::Util::Timer)
      give(dictaphone).play(nil) {[
        Value::Observation.new(1, :limit, [0], 1),
        Value::Observation.new(2, :limit, [1], 2),
        Value::Observation.new(3, :limit, [2], 3)
      ]}
      test_plan = PrescribesTestPlan.new.prescribe(:multiply,
        :subject => lambda {|n|
          if n == 1
            give(timer).time_up? { true }
          end
          n + 1
        },
        :random_seed => nil,
        :time_limit => 10 #<-- seconds
      )

      result = @subject.test(test_plan)

      verify!(timer).initialize(10)
      assert_equal 2, result.passed_count
      assert_equal 1, result.skipped_count
    end

    def test_no_calls
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      test_plan = PrescribesTestPlan.new.prescribe(:multiply,
        :subject => lambda {|a,b,c| a * b * c }
      )
      give(dictaphone).play(nil) { [] }

      result = @subject.test(test_plan)

      assert_equal false, result.failed?
      assert_equal true, result.ran_all_tests?
      assert_equal 0, result.total_count
      assert_equal 0, result.passed_count
      assert_equal 0, result.failed_count
      assert_equal 0, result.skipped_count
      assert_equal 0, result.errored_count
      assert_equal [], result.results
    end
  end
end
