module Suture::Surgeon
  class NoOpTest < UnitTest
    def setup
      super
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

    def test_new_path_defined
      plan = Suture::Value::Plan.new(
        :new => lambda {|a,b,c| a + b + c},
        :args => [1, 3, 5]
      )

      result = @subject.operate(plan)

      assert_equal 9, result
    end

    def test_old_and_new_path_defined
      plan = Suture::Value::Plan.new(
        :old => lambda {|a,b,c| raise "EWW" },
        :new => lambda {|a,b,c| a + b + c},
        :args => [1, 3, 5]
      )

      result = @subject.operate(plan)

      assert_equal 9, result
    end

    def test_old_and_new_path_defined_but_suture_is_disabled
      plan = Suture::Value::Plan.new(
        :old => lambda {|a,b,c| a + b + c},
        :new => lambda {|a,b,c| raise "no i am disable" },
        :args => [1, 3, 5],
        :disable => true
      )

      result = @subject.operate(plan)

      assert_equal 9, result
    end
  end
end
