require "suture/util/scalpel"
require "suture/create/builds_plan"

module Suture::Util
  class ScalpelTest < UnitTest
    def setup
      super
      @subject = Scalpel.new
    end

    def test_invokes_with_arg_override
      plan = Suture::BuildsPlan.new.build(:lol,
        :old => lambda { |*args| args },
        :args => [:no, :this, :is, :wrong]
      )

      result = @subject.cut(plan, :old, ['woo!'])

      assert_equal ['woo!'], result
    end

    def test_invokes_old_with_after
      after_old_args = nil
      plan = Suture::BuildsPlan.new.build(:my_seam,
        :old => lambda { |a,b| :old_result },
        :after_old => lambda { |*args| after_old_args = args },
        :args => [:a, :b]
      )

      result = @subject.cut(plan, :old)

      assert_equal :old_result, result
      assert_equal [
        :my_seam,
        [:a, :b],
        :old_result
      ], after_old_args
    end

    def test_invokes_old_with_no_after_defined
      plan = Suture::BuildsPlan.new.build(:my_seam,
        :old => lambda { |a,b| :old_result },
        :args => [:a, :b]
      )

      result = @subject.cut(plan, :old)

      assert_equal :old_result, result
    end

    def test_invokes_on_new_error_when_defined
      on_new_error_args = nil
      some_error = StandardError.new("LOLOLOL")
      plan = Suture::BuildsPlan.new.build(:my_seam,
        :new => lambda { |a,b| raise some_error },
        :on_new_error => lambda { |*args| on_new_error_args = args },
        :args => [:c, :d]
      )

      assert_raises(StandardError) { @subject.cut(plan, :new) }

      assert_equal [
        :my_seam,
        [:c, :d],
        some_error
      ], on_new_error_args
    end

    def test_doesnt_invoke_on_new_error_when_expected_error
      on_new_error_called = false
      plan = Suture::BuildsPlan.new.build(:my_seam,
        :old => lambda { raise ZeroDivisionError.new },
        :on_old_error => lambda { |*args| on_new_error_called = true },
        :args => [],
        :expected_error_types => [ZeroDivisionError]
      )

      assert_raises(ZeroDivisionError) { @subject.cut(plan, :old) }

      assert_equal false, on_new_error_called
    end
  end
end

