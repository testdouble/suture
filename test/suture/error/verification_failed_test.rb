require "suture/verify/prescribes_test_plan"
require "suture/value/test_results"

require "support/assertions"

module Suture::Error
  class VerificationFailedTest < Minitest::Test
    include Support::Assertions

    def test_single_failure
      test_plan = Suture::PrescribesTestPlan.new.prescribe(:pets, {
        :fail_fast => false,
        :random_seed => 998,
        :time_limit => 30
      })

      error = VerificationFailed.new(test_plan, Suture::Value::TestResults.new([
        {
          :observation => Suture::Value::Observation.new(
            42,
            :pets,
            ["Molly"],
            :dog
          ),
          :new_result => :cat,
          :passed => false,
          :ran => true
        }
      ]))

      expected_message = <<-MSG.gsub(/^ {8}/,'')

        # Verification of your seam failed!

        Descriptions of each unsuccessful verification follows:

        ## Failures

        1.) Recorded call for seam :pets (ID: 42) ran and failed comparison.

           Arguments: ```
             ["Molly"]
           ```
           Expected result: ```
             :dog
           ```
           Actual result: ```
             :cat
           ```

           Ideas to fix this:
             * Focus on this test by setting ENV var `SUTURE_VERIFY_ONLY=42`
             * Is the recording wrong? Delete it! `Suture.delete(42)`

        ### Fixing these failures

        #### Custom comparator

        If any comparison is failing and you believe the results are
        equivalent, we suggest you look into creating a custom comparator.
        See more details here:

          https://github.com/testdouble/suture#creating-a-custom-comparator

        #### Random seed

        Suture runs all verifications in random order by default. If you're
        seeing an erratic failure, it's possibly due to order-dependent
        behavior somewhere in your subject's code.

        To re-run the tests with the same random seed as was used in this run,
        set the env var `SUTURE_RANDOM_SEED=998` or the config entry
        `:random_seed => 998`.

        To re-run the tests without added shuffling (that is, in the order the
        calls were recorded in), then set the random seed explicitly to nil
        with env var `SUTURE_RANDOM_SEED=nil` or the config entry
        `:random_seed => nil`.

        # Configuration

        This is the configuration used by this test run:

        ```
        {
          :comparator => Suture::Comparator.new, # (in: `lib/suture/comparator.rb:3`)
          :database_path => "db/suture.sqlite3",
          :fail_fast => false,
          :call_limit => nil, # (no limit)
          :time_limit => 30, # (in seconds)
          :error_message_limit => nil, # (no limit)
          :random_seed => 998
        }
        ```

        # Result Summary

          - Passed........0
          - Failed........1
            - with error..0
          - Skipped.......0
          - Total calls...1
      MSG
      assert_equal expected_message, error.message
    end

    def test_the_kitchen_sink
      test_plan = Suture::PrescribesTestPlan.new.prescribe(:pets, {
        :comparator => lambda {|left, right| left == right },
        :database_path => "lol.db",
        :fail_fast => true,
        :call_limit => 42,
        :random_seed => nil
      })
      error = VerificationFailed.new(test_plan, Suture::Value::TestResults.new([
        {
          :observation => "blah",
          :passed => true,
          :ran => true
        },
        {
          :observation => Suture::Value::Observation.new(
            42,
            :pets,
            ["Molly"],
            :dog
          ),
          :new_result => :cat,
          :passed => false,
          :ran => true
        },
        {
          :observation => Suture::Value::Observation.new(
            43,
            :pets,
            ["Jill"],
            :turtle
          ),
          :error => StandardError.new("Yikes"),
          :passed => false,
          :ran => true
        },
        {
          :observation => Suture::Value::Observation.new(
            44,
            :pets,
            ["Joey"],
            :parrot
          ),
          :ran => false
        }
      ]))

      expected_message = <<-MSG.gsub(/^ {8}/,'')

        # Verification of your seam failed!

        Descriptions of each unsuccessful verification follows:

        ## Failures

        1.) Recorded call for seam :pets (ID: 42) ran and failed comparison.

           Arguments: ```
             ["Molly"]
           ```
           Expected result: ```
             :dog
           ```
           Actual result: ```
             :cat
           ```

           Ideas to fix this:
             * Focus on this test by setting ENV var `SUTURE_VERIFY_ONLY=42`
             * Is the recording wrong? Delete it! `Suture.delete(42)`

        2.) Recorded call for seam :pets (ID: 43) ran and raised an error.

           Arguments: ```
             ["Jill"]
           ```
           Expected result: ```
             :turtle
           ```
           Error raised: ```
             #<StandardError: Yikes>
           ```

           Ideas to fix this:
             * Focus on this test by setting ENV var `SUTURE_VERIFY_ONLY=43`
             * Is the recording wrong? Delete it! `Suture.delete(43)`

        ### Fixing these failures

        #### Custom comparator

        If any comparison is failing and you believe the results are
        equivalent, we suggest you look into creating a custom comparator.
        See more details here:

          https://github.com/testdouble/suture#creating-a-custom-comparator

        #### Random seed

        Suture runs all verifications in random order by default. If you're
        seeing an erratic failure, it's possibly due to order-dependent
        behavior somewhere in your subject's code.

        This test was run in insertion order (by the primary key of the table
        that stores calls, ascending). This is sometimes necessary when the
        code has an order-dependent side effect, but shouldn't be set unless it's
        clearly necessary, so as not to incidentally encourage _porting over_
        that temporal side effect to the new code path. To restore random
        ordering, unset the env var `SUTURE_RANDOM_SEED` and/or the config entry
        `:random_seed`.

        # Configuration

        This is the configuration used by this test run:

        ```
        {
          :comparator => Proc, # (in: `test/suture/error/verification_failed_test.rb:109`)
          :database_path => "lol.db",
          :fail_fast => true,
          :call_limit => 42,
          :time_limit => nil, # (no limit)
          :error_message_limit => nil, # (no limit)
          :random_seed => nil # (insertion order)
        }
        ```

        # Result Summary

          - Passed........1
          - Failed........2
            - with error..1
          - Skipped.......1
          - Total calls...4
      MSG
      assert_equal expected_message, error.message
    end

    def test_error_message_limit
      test_plan = Suture::PrescribesTestPlan.new.prescribe(:pets, {
        :error_message_limit => 2
      })
      error = VerificationFailed.new(test_plan, Suture::Value::TestResults.new(
        20.times.map { |i|
          {
            :observation => Suture::Value::Observation.new(
              i,
              :blah,
              ["blaw"],
              :blog
            ),
            :new_result => :blech,
            :passed => false,
            :ran => true
          }
        }
      ))

      assert_match "1.)", error.message
      assert_match "(ID: 1)", error.message
      assert_match "2.)", error.message
      assert_not_match "3.)", error.message
      assert_match "(18 more failure messages were hidden because :error_message_limit was set to 2.)", error.message
      assert_match ":error_message_limit => 2,", error.message
      assert_match "- Failed........20", error.message
    end
  end
end

