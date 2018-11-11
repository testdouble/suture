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

      result = @subject.cut(plan, :old, ["woo!"])

      assert_equal ["woo!"], result
    end

    def test_invokes_old_with_after
      after_old_args = nil
      plan = Suture::BuildsPlan.new.build(:my_seam,
        :old => lambda { |a, b| :old_result },
        :after_old => lambda { |*args| after_old_args = args },
        :args => [:a, :b]
      )

      result = @subject.cut(plan, :old)

      assert_equal :old_result, result
      assert_equal [
        [:a, :b],
        :old_result
      ], after_old_args
    end

    def test_invokes_old_with_no_after_defined
      plan = Suture::BuildsPlan.new.build(:my_seam,
        :old => lambda { |a, b| :old_result },
        :args => [:a, :b]
      )

      result = @subject.cut(plan, :old)

      assert_equal :old_result, result
    end

    def test_invokes_on_new_error_when_defined
      on_new_error_args = nil
      some_error = StandardError.new("LOLOLOL")
      plan = Suture::BuildsPlan.new.build(:my_seam,
        :new => lambda { |a, b| raise some_error },
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
      on_old_error_called = false
      plan = Suture::BuildsPlan.new.build(:my_seam,
        :old => lambda { raise ZeroDivisionError.new },
        :on_old_error => lambda { |*args| on_old_error_called = true },
        :args => [],
        :expected_error_types => [ZeroDivisionError]
      )

      assert_raises(ZeroDivisionError) { @subject.cut(plan, :old) }
      assert_equal false, on_old_error_called
    end

    def test_log_errors_when_unexpected
      Suture.config(:log_io => log_io = StringIO.new)
      Suture::Adapter::Log.reset!

      plan = Suture::BuildsPlan.new.build(:my_seam,
        :old => lambda { |a, b| 100 / 0 },
        :args => [1, 2]
      )

      assert_raises(ZeroDivisionError) { @subject.cut(plan, :old) }
      assert_spacey_match log_io.tap(&:rewind).read, <<-MSG.gsub(/^ {8}/, "")
        Suture invoked the :my_seam seam's :old code path with args: ```
          [1, 2]
        ```
        which raised a ZeroDivisionError with message: ```
          divided by 0
        ```
      MSG
    end

    def test_does_not_log_errors_when_expected
      Suture.config(:log_io => log_io = StringIO.new)
      Suture::Adapter::Log.reset!
      plan = Suture::BuildsPlan.new.build(:my_seam,
        :old => lambda { |a, b| 100 / 0 },
        :args => [1, 2],
        :expected_error_types => [ZeroDivisionError]
      )

      assert_raises(ZeroDivisionError) { @subject.cut(plan, :old) }

      assert_equal "", log_io.tap(&:rewind).read
    end

    def test_deep_dup_args_when_set
      arg = [[{:a => 1}]]
      plan = Suture::BuildsPlan.new.build(:my_seam,
        :old => lambda { |a| a[0][0][:a] = :trollface },
        :args => [arg],
        :dup_args => true
      )

      @subject.cut(plan, :old)

      assert_equal [[{:a => 1}]], arg
    end
  end
end

