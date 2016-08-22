require "suture/prescribes_test_plan"
require "suture/value/test_results"

module Suture::Error
  class VerificationFailedTest < Minitest::Test
    def test_single_failure
      test_plan = Suture::PrescribesTestPlan.new.prescribe(:pets, {
        :fail_fast => false
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
             * Is the recording wrong? Delete it! `Suture.delete(42)`

        If any comparison is failing and you believe the results are
        equivalent, we suggest you look into creating a custom comparator.
        See more details here:

          https://github.com/testdouble/suture#creating-a-custom-comparator

        # Configuration

        {
          :comparator => Suture::Comparator (in: `lib/suture/comparator.rb:3`),
          :database_path => "db/suture.sqlite3",
          :fail_fast => false
        }

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
        :fail_fast => true
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
             * Is the recording wrong? Delete it! `Suture.delete(43)`

        If any comparison is failing and you believe the results are
        equivalent, we suggest you look into creating a custom comparator.
        See more details here:

          https://github.com/testdouble/suture#creating-a-custom-comparator

        # Configuration

        {
          :comparator => Proc (in: `test/suture/error/verification_failed_test.rb:75`),
          :database_path => "lol.db",
          :fail_fast => true
        }

        # Result Summary

          - Passed........1
          - Failed........2
            - with error..1
          - Skipped.......1
          - Total calls...4
      MSG
      assert_equal expected_message, error.message
    end
  end
end

