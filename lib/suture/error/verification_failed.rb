module Suture::Error
  class VerificationFailed < StandardError
    def initialize(results)
      super
      @results = results
    end

    def message
      [
        intro,
        describe_failures(@results.failed),
        summarize(@results)
      ].join("\n")
    end

    private

    def intro
      <<-MSG.gsub(/^ {8}/,'')

        # Verification of your seam failed!

        Descriptions of each unsuccessful verification follows:
      MSG
    end

    def summarize(results)
      <<-MSG.gsub(/^ {8}/,'')
        # Result Summary
          - Passed........#{results.passed_count}
          - Failed........#{results.failed_count}
            - with error..#{results.errored_count}
          - Skipped.......#{results.skipped_count}
          - Total calls...#{results.total_count}
      MSG
    end

    def describe_failures(failures)
      return if failures.empty?
      <<-MSG.gsub(/^ {8}/,'')
        ## Failures

        #{failures.each_with_index.map { |failure, index|
            describe_failure(failure, index)
          }.join("\n")}
        If any of the above failures were marked in error, consider implementing
        a custom comparator (TODO: not implemented yet) or deleting the record
        from Suture's database (TODO: not implemented yet).
      MSG
    end

    def describe_failure(failure, index)
      expected = failure[:observation]
      return <<-MSG.gsub(/^ {8}/,'')
        #{index + 1}.) Recorded call for seam #{expected.name.inspect} (ID: #{expected.id}) ran and failed comparison.

           Arguments: ```
             #{expected.args.inspect}
           ```
           Expected result: ```
             #{expected.result.inspect}
           ```
           Actual result: ```
             #{failure[:new_result].inspect}
           ```
      MSG
    end

  end
end
