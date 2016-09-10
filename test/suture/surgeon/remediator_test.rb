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

    def test_call_old_if_fallback_on_mismatch
      old_called = false
      plan = Suture::BuildsPlan.new.build(:thing,
        :old => lambda { old_called = true; :old_result },
        :new => lambda { :new_result },
        :args => [],
        :fallback_on_error => true,
        :fallback_on_mismatch => true
      )
      @subject.operate(plan)

      assert_equal true, old_called
    end

    def test_return_result_when_match_if_fallback_on_mismatch
      plan = Suture::BuildsPlan.new.build(:thing,
        :old => lambda { :same_result },
        :new => lambda { :same_result },
        :args => [],
        :fallback_on_error => true,
        :fallback_on_mismatch => true
      )
      result = @subject.operate(plan)

      assert_equal :same_result, result
    end

    def test_return_old_result_when_mismtach_if_fallback_on_mismatch
      plan = Suture::BuildsPlan.new.build(:thing,
        :old => lambda { :old_result },
        :new => lambda { :new_result },
        :args => [],
        :fallback_on_error => true,
        :fallback_on_mismatch => true
      )
      result = @subject.operate(plan)

      assert_equal :old_result, result
    end
  end
end
