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
      observation = Value::Observation.new(:args => [], :result => 5)

      result = @subject.administer(plan, observation)

      assert_equal({
        :new_result => 5,
        :passed => true
      }, result)
    end

    def test_failing_result
      plan = Value::TestPlan.new(
        :subject => lambda { "this is not 5" },
        :args => [],
        :comparator => Suture::Comparator.new
      )
      observation = Value::Observation.new(:args => [], :result => 5)

      result = @subject.administer(plan, observation)

      assert_equal({
        :new_result => "this is not 5",
        :passed => false
      }, result)
    end

    def test_unexpected_error
      some_error = ZeroDivisionError.new
      plan = Value::TestPlan.new(
        :subject => lambda { raise some_error },
        :args => []
      )
      observation = Value::Observation.new(:args => [], :result => 5)

      result = @subject.administer(plan, observation)

      assert_equal({
        :error => some_error,
        :passed => false
      }, result)
    end

    def test_expected_error
    end
  end
end
