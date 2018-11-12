module Suture
  class AdministersTestTest < UnitTest
    def setup
      super
      @subject = AdministersTest.new
    end

    def test_passing_result
      plan = Value::TestPlan.new(
        :subject => lambda { 5 },
        :args => [],
        :comparator => Suture::Comparator.new
      )
      observation = Value::Observation.new(:args => [], :return => 5)

      result = @subject.administer(plan, observation)

      assert_equal({
        :new_result => Value::Result.returned(5),
        :passed => true,
      }, result)
    end

    def test_failing_result
      plan = Value::TestPlan.new(
        :subject => lambda { "this is not 5" },
        :args => [],
        :comparator => Suture::Comparator.new
      )
      observation = Value::Observation.new(:args => [], :return => 5)

      result = @subject.administer(plan, observation)

      assert_equal({
        :new_result => Value::Result.returned("this is not 5"),
        :passed => false,
      }, result)
    end

    def test_unexpected_error
      some_error = ZeroDivisionError.new
      plan = Value::TestPlan.new(
        :subject => lambda { raise some_error },
        :args => []
      )
      observation = Value::Observation.new(:args => [], :return => 5)

      result = @subject.administer(plan, observation)

      assert_equal({
        :error => some_error,
        :passed => false,
      }, result)
    end

    def test_expected_error_that_matches
      some_error = ZeroDivisionError.new("HEYY")
      plan = Value::TestPlan.new(
        :subject => lambda { raise some_error },
        :args => []
      )
      observation = Value::Observation.new(:args => [], :error => some_error)

      result = @subject.administer(plan, observation)

      assert_equal({
        :new_result => Value::Result.errored(some_error),
        :passed => true,
      }, result)
    end

    def test_expected_error_that_does_not_match
      expected_error = ZeroDivisionError.new("HEYY")
      actual_error = ZeroDivisionError.new("BYYYYEEEE")
      plan = Value::TestPlan.new(
        :subject => lambda { raise actual_error },
        :args => []
      )
      observation = Value::Observation.new(:args => [], :error => expected_error)

      result = @subject.administer(plan, observation)

      assert_equal({
        :new_result => Value::Result.errored(actual_error),
        :passed => false,
      }, result)
    end
  end
end
