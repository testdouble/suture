module Suture::Error
  class ResultMismatchTest < UnitTest
    def test_simple_mismatch
      plan = Suture::Value::Plan.new(:name => :SEAM, :args => [1, 2, 3])
      new = Suture::Value::Result.returned("A")
      old = Suture::Value::Result.errored(ZeroDivisionError.new("B"))

      subject = ResultMismatch.new(plan, new, old)

      assert_spacey_match subject.message, <<-MSG.gsub(/^ {8}/, "")
        The results from the old & new code paths did not match for the seam
        :SEAM and Suture is raising this error because the `:call_both`
        option is enabled, because both code paths are expected to return the
        same result.

        Arguments: ```
          [1, 2, 3]
        ```
        The new code path returned value: ```
          "A"
        ```
        The old code path raised error: ```
          #<ZeroDivisionError: B>
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
    end
  end
end
