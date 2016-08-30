require "suture/adapter/dictaphone"

module Suture::Surgeon
  class ObserverTest < UnitTest
    def setup
      super
      @subject = Observer.new
    end

    def test_record_calls
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      plan = Suture::Value::Plan.new(
        :old => lambda {|arg1| "#{arg1} pants" },
        :args => [5]
      )

      result = @subject.operate(plan)

      assert_equal "5 pants", result
      verify!(dictaphone).initialize(plan)
      verify(dictaphone).record("5 pants")
    end

    def test_record_expected_errors
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      some_error = ZeroDivisionError.new
      plan = Suture::Value::Plan.new(
        :old => lambda { raise some_error },
        :args => [],
        :expected_error_types => [ZeroDivisionError]
      )

      assert_raises(ZeroDivisionError) { @subject.operate(plan) }

      verify(dictaphone).record_error(some_error)
    end

    def test_skip_unexpected_errors
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      some_error = ZeroDivisionError.new
      plan = Suture::Value::Plan.new(
        :old => lambda { raise some_error },
        :args => []
      )

      assert_raises(ZeroDivisionError) { @subject.operate(plan) }

      verify(dictaphone, 0.times).record_error(some_error)
    end
  end
end
