module Suture::Error
  class VerificationFailed < StandardError
    def initialize(plan, results)
      @plan = plan
      @results = results
    end

    def message
      [
        intro,
        describe_failures(@results.failed, @plan),
        configuration(@plan),
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

    def configuration(plan)
      <<-MSG.gsub(/^ {8}/,'')
        # Configuration

        This is the configuration used by this test run:

        ```
        {
          :comparator => #{describe_comparator(plan.comparator)}
          :database_path => #{plan.database_path.inspect},
          :fail_fast => #{plan.fail_fast},
          :random_seed => #{plan.random_seed ? plan.random_seed : "nil # (insertion order)"}
        }
        ```
      MSG
    end

    def describe_comparator(comparator)
      if comparator.kind_of?(Proc)
        "Proc, # (in: `#{describe_source_location(*comparator.source_location)}`)"
      elsif comparator.respond_to?(:method) && comparator.method(:call)
        "#{comparator.class}.new, # (in: `#{describe_source_location(*comparator.method(:call).source_location)}`)"
      end
    end

    def describe_source_location(file, line)
      root = File.join(Dir.getwd, "/")
      path = file.start_with?(root) ? file.gsub(root, '') : file
      "#{path}:#{line}"
    end

    def describe_failures(failures, plan)
      return if failures.empty?
      [
        "## Failures\n",
        failures.each_with_index.map { |failure, index|
          describe_failure(failure, index)
        },
        describe_general_failure_advice(plan)
      ].join("\n")
    end

    def describe_failure(failure, index)
      expected = failure[:observation]
      return <<-MSG.gsub(/^ {8}/,'')
        #{index + 1}.) Recorded call for seam #{expected.name.inspect} (ID: #{expected.id}) ran and #{failure[:error] ? "raised an error" : "failed comparison"}.

           Arguments: ```
             #{expected.args.inspect}
           ```
           Expected result: ```
             #{expected.result.inspect}
           ```
           #{failure[:error] ? "Error raised" : "Actual result"}: ```
             #{if failure[:error]
                 stringify_error(failure[:error])
               else
                 failure[:new_result].inspect
               end
             }
           ```

           Ideas to fix this:
             * Focus on this test by setting ENV var `SUTURE_VERIFY_ONLY=#{expected.id}`
             * Is the recording wrong? Delete it! `Suture.delete(#{expected.id})`
      MSG
    end

    def describe_general_failure_advice(plan)
      <<-MSG.gsub(/^ {8}/,'')
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

        #{if !plan.random_seed.nil?
            <<-MOAR.gsub(/^ {14}/,'')
              To re-run the tests with the same random seed as was used in this run,
              set the env var `SUTURE_RANDOM_SEED=#{plan.random_seed}` or the config entry
              `:random_seed => #{plan.random_seed}`.

              To re-run the tests without added shuffling (that is, in the order the
              calls were recorded in), then set the random seed explicitly to nil
              with env var `SUTURE_RANDOM_SEED=nil` or the config entry
              `:random_seed => nil`.
            MOAR
          else
            <<-MOAR.gsub(/^ {14}/,'')
              This test was run in insertion order (by the primary key of the table
              that stores calls, ascending). This is sometimes necessary when the
              code has an order-dependent side effect, but shouldn't be set unless it's
              clearly necessary, so as not to incidentally encourage _porting over_
              that temporal side effect to the new code path. To restore random
              ordering, unset the env var `SUTURE_RANDOM_SEED` and/or the config entry
              `:random_seed`.
            MOAR
          end.chomp}
      MSG
    end


    def stringify_error(error)
      s = error.inspect
      s += "\n" + error.backtrace.join("\n") if error.backtrace
      s
    end
  end
end
