require "suture/error/invalid_plan"

module Suture
  class ValidatesPlan
    REQUIREMENTS = {
      :name => "in order to identify recorded calls",
      :old => "in order to call the legacy code path (must respond to `:call`)",
      :args => "in order to differentiate recorded calls (if the code you're changing doesn't take arguments, consider creating a seam inside of it which can--consult the README for more advice)"
    }

    VALIDATIONS = {
      :name => {
        :test => lambda { |name| name.size < 256 },
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

    def validate(plan)
      if (missing = REQUIREMENTS.select {|(name, _)| !plan.send(name) }).any?
        raise Error::InvalidPlan.missing_requirements(missing)
      elsif (invalids = VALIDATIONS.select { |name, rule|
              next unless attr = plan.send(name)
              !rule[:test].call(attr)
            }).any?
        raise Error::InvalidPlan.invalid_options(invalids)
      else
        plan
      end
    end
  end
end
