module Suture::Surgeon
  class NoOpTest < Minitest::Test
    def setup
      @subject = NoOp.new
    end

    def test_no_path_defined
      plan = Suture::Value::Plan.new

      result = @subject.operate(plan)

      assert_equal nil, result
    end

    def test_old_path_defined
      plan = Suture::Value::Plan.new(
        :old => lambda {|a,b,c| a + b + c},
        :args => [1, 3, 5]
      )

      result = @subject.operate(plan)

      assert_equal 9, result
    end
  end
end
