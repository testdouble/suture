require "suture/value/test_results"

module Suture::Error
  class VerificationFailedTest < Minitest::Test
    def test_single_failure
      error = VerificationFailed.new(Suture::Value::TestResults.new([
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

        If any of the above failures were marked in error, consider implementing
        a custom comparator (TODO: not implemented yet) or deleting the record
        from Suture's database (TODO: not implemented yet).

        # Result Summary
          - Passed........0
          - Failed........1
            - with error..0
          - Skipped.......0
          - Total calls...1
      MSG
      assert_equal expected_message, error.message
    end
  end
end

