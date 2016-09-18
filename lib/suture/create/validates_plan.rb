require "suture/error/invalid_plan"

module Suture
  class ValidatesPlan
    REQUIREMENTS = {
      :name => "in order to identify recorded calls",
      :old => "in order to call the legacy code path (must respond to `:call`)",
      :args => "in order to differentiate recorded calls (if the code you're changing doesn't take arguments, you can set :args to `[]` but should probably consider creating a seam inside of it which can--consult the README for more advice)"
    }

    VALIDATIONS = {
      :name => {
        :test => lambda { |name| name.to_s.size < 256 },
        :message => "must be less than 256 characters"
      },
      :old => CALLABLE_VALIDATION = ({
        :test => lambda { |old| old.respond_to?(:call) },
        :message => "must respond to `call` (e.g. `dog.method(:bark)` or `->(*args){ dog.bark(*args) }`)"
      }),
      :new => CALLABLE_VALIDATION,
      :comparator => CALLABLE_VALIDATION.merge(
        :message => "must respond to `call` (e.g. `MyComparator.new` or `->(recorded, actual) { recorded == actual }`)"
      )
    }

    CONFLICTS = [
      lambda { |plan|
        if plan.record_calls && !plan.database_path
          ":record_calls is enabled, but :database_path is nil, so Suture doesn't know where to record calls to the seam."
        end
      },
      lambda { |plan|
        if plan.record_calls && plan.call_both
          ":record_calls & :call_both are both enabled and conflict with one another. :record_calls will only invoke the old code path (intended for characterization of the old code path and initial development of the new code path), whereas :call_both will invoke the new path and the old to compare their results after development of the new code path is initially complete (typically in a pre-production environment to validate the behavior of the new code path is consistent with the old). If you're still actively developing the new code path and need more recordings to feed Suture.verify, disable :call_both; otherwise, it's likely time to turn off :record_calls on this seam."
        end
      },
      lambda { |plan|
        if plan.record_calls && plan.fallback_on_error
          ":record_calls & :fallback_on_error are both enabled and conflict with one another. :record_calls will only invoke the old code path (intended for characterization of the old code path and initial development of the new code path), whereas :fallback_on_error will call the new code path unless an error is raised, in which case it will fall back on the old code path."
        end
      },
      lambda { |plan|
        if plan.call_both && plan.fallback_on_error
          ":call_both & :fallback_on_error are both enabled and conflict with one another. :call_both is designed for pre-production environments and will call both the old and new code paths to compare their results, whereas :fallback_on_error is designed for production environments where it is safe to call the old code path in the event that the new code path fails unexpectedly"
        end
      },
      lambda { |plan|
        if plan.call_both && !plan.new.respond_to?(:call)
          ":call_both is set but :new is either not set or is not callable. In order to call both code paths, both :old and :new must be set and callable."
        end
      },
      lambda { |plan|
        if plan.fallback_on_error && !plan.new.respond_to?(:call)
          ":fallback_on_error is set but :new is either not set or is not callable. This mode is designed for after the :new code path has been developed and run in production-like environments, where :old is only kept around as a fallback to retry in the event that :new raises an unexpected error. Either specify a :new code path or disable :fallback_on_error."
        end
      },
      lambda { |plan|
        if !plan.raise_on_result_mismatch && !plan.call_both
          ":raise_on_result_mismatch was disabled but :call_both is not enabled. This option only applies to the :call_both mode, and will have no impact when set for other modes"
        end
      }
    ]

    def validate(plan)
      if (missing = missing_attrs(plan)).any?
        raise Error::InvalidPlan.missing_requirements(missing)
      elsif (invalids = invalid_attrs(plan)).any?
        raise Error::InvalidPlan.invalid_options(invalids)
      elsif (conflicts = conflicting_attrs(plan)).any?
        raise Error::InvalidPlan.conflicting_options(conflicts)
      else
        plan
      end
    end

    def missing_attrs(plan)
      REQUIREMENTS.select { |(name, _)|
        !plan.send(name)
      }
    end

    def invalid_attrs(plan)
      VALIDATIONS.select { |name, rule|
        next unless attr = plan.send(name)
        !rule[:test].call(attr)
      }
    end

    def conflicting_attrs(plan)
      CONFLICTS.map { |rule|
        rule.call(plan)
      }.compact
    end
  end
end
