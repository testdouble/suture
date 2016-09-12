require "suture/surgeon/remediator"
require "suture/create/builds_plan"

module Suture::Surgeon
  class RemediatorTest < UnitTest
    def setup
      super
      @subject = Remediator.new
    end

    def test_retry_when_new_raises
      plan = Suture::BuildsPlan.new.build(:thing,
        :old => lambda { :old_result },
        :new => lambda { raise "Hell" },
        :args => [],
        :fallback_on_error => true
      )

      result = @subject.operate(plan)

      assert_equal :old_result, result
    end

    def test_dont_retry_when_new_doesnt_raise
      old_called = false
      plan = Suture::BuildsPlan.new.build(:thing,
        :old => lambda { old_called = true; :old_result },
        :new => lambda { :new_result },
        :args => [],
        :fallback_on_error => true
      )

      result = @subject.operate(plan)

      assert_equal :new_result, result
      assert_equal false, old_called
    end

    def test_dont_retry_when_expected_error_type
      old_called = false
      plan = Suture::BuildsPlan.new.build(:thing,
        :old => lambda { old_called = true; :old_result },
        :new => lambda { 5 / 0 },
        :args => [],
        :fallback_on_error => true,
        :expected_error_types => [ZeroDivisionError]
      )

      assert_raises(ZeroDivisionError) { @subject.operate(plan) }
      assert_equal false, old_called
    end

    def test_compare_old_result_when_raise_on_error_mismatch
      old_called = false
      plan = Suture::BuildsPlan.new.build(:thing,
        :old => lambda { old_called = true; :same_result },
        :new => lambda { :same_result },
        :args => [],
        :fallback_on_error => true,
        :raise_on_result_mismatch => true
      )
      result = @subject.operate(plan)
      assert_equal :same_result, result
      assert_equal true, old_called
    end

    def test_use_old_result_when_result_mismatches
      plan = Suture::BuildsPlan.new.build(:thing,
        :old => lambda { :old_result },
        :new => lambda { :new_result },
        :args => [],
        :fallback_on_error => true,
        :raise_on_result_mismatch => true
      )
      result = @subject.operate(plan)
      assert_equal :old_result, result
    end

    def test_call_old_just_once_when_result_mismatches
      old_called_times = 0
      plan = Suture::BuildsPlan.new.build(
        :thing,
        :old => lambda { old_called_times += 1; :old_result },
        :new => lambda { :new_result },
        :args => [],
        :fallback_on_error => true,
        :raise_on_result_mismatch => true
      )
      result = @subject.operate(plan)
      assert_equal :old_result, result
      assert_equal 1, old_called_times
    end
  end
end
