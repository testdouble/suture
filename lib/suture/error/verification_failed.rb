module Suture::Error
  class VerificationFailed < StandardError
    def initialize(plan, results)
      @plan = plan
      @results = results
    end

    def message
      [
        intro,
        describe_failures(@results.failed),
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

        {
          :comparator => #{describe_comparator(plan.comparator)},
          :database_path => #{plan.database_path.inspect},
          :fail_fast => #{plan.fail_fast}
        }
      MSG
    end

    def describe_comparator(comparator)
      if comparator.kind_of?(Proc)
        "Proc (in: `#{describe_source_location(*comparator.source_location)}`)"
      else comparator.respond_to?(:method) && comparator.method(:call)
        "#{comparator.class} (in: `#{describe_source_location(*comparator.method(:call).source_location)}`)"
      end
    end

    def describe_source_location(file, line)
      root = File.join(Dir.getwd, "/")
      path = if file.start_with?(root)
        file.gsub(root, '')
      else
        file
      end
      "#{path}:#{line}"
    end

    def describe_failures(failures)
      return if failures.empty?
      [
        "## Failures\n",
        failures.each_with_index.map { |failure, index|
          describe_failure(failure, index)
        }
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
      MSG
    end

    def stringify_error(error)
      s = error.inspect
      s += "\n" + error.backtrace.join("\n") if error.backtrace
      s
    end
  end
end
