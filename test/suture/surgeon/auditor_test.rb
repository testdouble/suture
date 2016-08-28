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
        :old => lambda { |a| [:woo] if a == :yay },
        :new => lambda { |a| new_result unless a != :yay },
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

      expected_message = <<-MSG.gsub(/^ {8}/,'')
        The results from the old & new code paths did not match for the seam
        :face_swap and Suture is raising this error because the `:call_both`
        option is enabled, because both code paths are expected to return the
        same result.

        Arguments: ```
          [:face]
        ```
        The new code path returned: ```
          :shrugface
        ```
        The old code path returned: ```
          :trollface
        ```

        Here's what we recommend you do next:

        1. Verify that this mismatch does not represent a missed requirement in
           the new code path. If it does, implement it!

        2. If either (or both) code path has a side effect that impacts the
           return value of the other, consider passing an `:after_old` and/or
           `:after_new` hook to clean up your application's state well enough to
           run both paths one-after-the-other safely.

        3. If the two return values above are sufficiently similar for the
           purpose of your application, consider writing your own custom
           comparator that relaxes the comparison (e.g. only checks equivalence
           of the attributes that matter). See the README for more info on custom
           comparators.

        4. If the new code path is working as desired (i.e. the old code path had
           a bug for this argument and you don't want to reimplement it just to
           make them perfectly in sync with one another), consider writing a
           one-off comparator for this seam that will ignore the affected range
           of arguments. See the README for more info on custom comparators.

        By default, Suture's :call_both mode will log a warning and raise an
        error when the results of each code path don't match. It is intended for
        use in any pre-production environment to "try out" the new code path
        before pushing it to production. If, for whatever reason, this error is
        too disruptive and logging is sufficient for monitoring results, you may
        disable this error by setting `:raise_on_result_mismatch` to false.
      MSG
      assert_equal expected_message, error.message
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
  end
end
