require "suture/create/performs_surgery"

module Suture
  class PerformsSurgeryTest < UnitTest
    def setup
      super
      @subject = PerformsSurgery.new
    end

    def test_any_surgeon
      plan = Value::Plan.new
      surgeon = gimme(Surgeon::NoOp)
      give(surgeon).operate(plan) { :pants }

      result = @subject.perform(plan, surgeon)

      assert_equal :pants, result
    end
  end
end
