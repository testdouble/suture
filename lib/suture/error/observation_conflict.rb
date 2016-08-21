module Suture::Error
  class ObservationConflict < StandardError
    def initialize(name, args, new_result, old_result)
      @name = name
      @args = args
      @new_result = new_result
      @old_result = old_result
    end

    def message
      <<-MSG.gsub(/^ {8}/,'')
        At suture #{@name.inspect} with inputs `#{@args.inspect}`, the newly-observed return value `#{@new_result.inspect}`
        conflicts with previously recorded return value `#{@old_result.inspect}`.

        That's not good! Here are a few ideas of what may have happened:

        1. The old code path may have a side effect that results in different
           return values. If it's possible, to create the suture at a point after
           this side effect. Otherwise, read on.

        2. Either environmental differents (e.g. system time resulting in a
           different timestamp) or side effects (e.g. saving to a database
           resulting in a different GUID value) mean that Suture is detecting two
           different results for the same inputs. This can be worked around by
           providing a custom comparator for the two values nearest common
           ancestor type. Comparator support is tracked here:
             https://github.com/testdouble/suture/issues/14

        3. If neither of the above are true, it's possible that the old code path
           was changed while still in the early stage of recording characterization
           calls (presumably by mistake). If such a change may have occurred in
           error, check your git history. Otherwise, perhaps you `record_calls` is
           accidentally still enabled and should be turned off for this suture
           (either with SUTURE_RECORD_CALLS=false or :record_calls => false).

        4. If the old recording was made in error, then you may want to delete it
           Deletion support via the Suture API is tracked here:
             https://github.com/testdouble/suture/issues/10

      MSG
    end
  end
end
