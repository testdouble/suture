module Suture
  class ChoosesSurgeonTest < Minitest::Test
    def setup
      @subject = ChoosesSurgeon.new
    end

    def test_no_op
      plan = Value::Plan.new(:old => ->{}, args: ['hi'])

      result = @subject.choose(plan)

      assert_kind_of Surgeon::NoOp, result
    end

    def test_development
    end
  end
end
