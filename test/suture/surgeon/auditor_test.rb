require "suture/surgeon/auditor"
require "suture/create/builds_plan"

module Suture::Surgeon
  class AuditorTest < UnitTest
    def setup
      super
      @subject = Auditor.new
    end

    def test_new_and_old_returns_new_result_when_equivalent
      new_result = [:woo]
      plan = Suture::BuildsPlan.new.build(:lol,
        :old => lambda { |a| [:woo] },
        :new => lambda { |a| new_result },
        :args => [:yay]
      )

      result = @subject.operate(plan)

      assert_equal new_result.__id__, result.__id__
    end

    def test_raises_when_new_and_old_differ
      plan = Suture::BuildsPlan.new.build(:face_swap,
        :old => lambda { |type| :trollface },
        :new => lambda { |type| :shrugface },
        :args => [:face],
        :raise_on_result_mismatch => true
      )

      error = assert_raises(Suture::Error::ResultMismatch) { @subject.operate(plan) }

      assert_spacey_match error.message, ":trollface"
    end

    def test_does_not_raise_when_raise_is_disabled
      plan = Suture::BuildsPlan.new.build(:face_swap,
        :old => lambda { |type| :trollface },
        :new => lambda { |type| :shrugface },
        :args => [:face],
        :raise_on_result_mismatch => false
      )

      result = @subject.operate(plan)

      assert_equal :shrugface, result
    end

    def test_raises_mismatch_when_new_raises_and_old_does_not
      plan = Suture::BuildsPlan.new.build(:face_swap,
        :old => lambda { |type| :trollface },
        :new => lambda { |type| raise ZeroDivisionError.new("shrugface") },
        :args => [:face]
      )

      error = assert_raises(Suture::Error::ResultMismatch) { @subject.operate(plan) }

      assert_spacey_match error.message, "new code path raised"
      assert_spacey_match error.message, "old code path returned"
    end

    def test_raises_mismatch_when_old_raises_and_new_does_not
      plan = Suture::BuildsPlan.new.build(:face_swap,
        :old => lambda { |type| raise ZeroDivisionError.new("trollface") },
        :new => lambda { |type| :shrugface },
        :args => [:face]
      )

      error = assert_raises(Suture::Error::ResultMismatch) { @subject.operate(plan) }

      assert_spacey_match error.message, "new code path returned"
      assert_spacey_match error.message, "old code path raised"
    end

    def test_raises_mismatch_when_new_raises_and_old_raises_different
      plan = Suture::BuildsPlan.new.build(:face_swap,
        :old => lambda { |type| raise ZeroDivisionError.new("trollface") },
        :new => lambda { |type| raise ZeroDivisionError.new("shrugface") },
        :args => [:face],
      )

      assert_raises(Suture::Error::ResultMismatch) { @subject.operate(plan) }
    end

    def test_raises_actual_when_new_raises_and_old_raises_same
      new_error = RuntimeError.new("trollface")
      plan = Suture::BuildsPlan.new.build(:face_swap,
        :old => lambda { |type| raise "trollface" },
        :new => lambda { |type| raise new_error },
        :args => [:face],
      )

      error = assert_raises { @subject.operate(plan) }

      assert_equal error.__id__, new_error.__id__
    end

    def test_raises_actual_when_raise_mismatch_disabled_and_new_raises_and_old_does_not
      plan = Suture::BuildsPlan.new.build(:face_swap,
        :old => lambda { |type| :trollface },
        :new => lambda { |type| raise ZeroDivisionError.new("shrugface") },
        :args => [:face],
        :raise_on_result_mismatch => false
      )

      error = assert_raises(ZeroDivisionError) { @subject.operate(plan) }

      assert_equal "shrugface", error.message
    end

    def test_returns_old_when_toggled_and_raise_disabled
      plan = Suture::BuildsPlan.new.build(:face_swap,
        :old => lambda { |type| :trollface },
        :new => lambda { |type| :shrugface },
        :args => [:face],
        :raise_on_result_mismatch => false,
        :return_old_on_result_mismatch => true
      )

      result = @subject.operate(plan)

      assert_equal :trollface, result
    end

    def test_passes_when_comparator_bails_them_out
      plan = Suture::BuildsPlan.new.build(:less_than_10,
        :old => lambda { 8 },
        :new => lambda { 7 },
        :args => [],
        :comparator => lambda {|old, new| old < 10 && new < 10 }
      )

      result = @subject.operate(plan)

      assert_equal 7, result
    end

    def test_raise_disabled_old_return_and_new_raises_return_old
      plan = Suture::BuildsPlan.new.build(:face_swap,
        :old => lambda { |type| :trollface },
        :new => lambda { |type| raise ZeroDivisionError.new("shrugface") },
        :args => [:face],
        :raise_on_result_mismatch => false,
        :return_old_on_result_mismatch => true
      )

      result = @subject.operate(plan)

      assert_equal :trollface, result
    end

    def test_raise_disabled_old_return_and_new_raises_and_old_raises_raise_old
      plan = Suture::BuildsPlan.new.build(:face_swap,
        :old => lambda { |type| raise ZeroDivisionError.new("trollface") },
        :new => lambda { |type| raise ZeroDivisionError.new("shrugface") },
        :args => [:face],
        :raise_on_result_mismatch => false,
        :return_old_on_result_mismatch => true
      )

      error = assert_raises(ZeroDivisionError) { @subject.operate(plan) }

      assert_equal "trollface", error.message
    end
  end
end
