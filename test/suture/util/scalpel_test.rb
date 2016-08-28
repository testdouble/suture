require "suture/util/scalpel"
require "suture/create/builds_plan"

module Suture::Util
  class ScalpelTest < Minitest::Test
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
        :old,
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
  end
end

