require "suture/error/invalid_plan"

module Suture
  class ValidatesPlan
    REQUIREMENTS = {
      :name => "in order to identify recorded calls",
      :old => "in order to call the legacy code path (must respond to `:call`)",
      :args => "in order to differentiate recorded calls (if the code you're changing doesn't take arguments, consider creating a seam inside of it which can--consult the README for more advice)"
    }
    def validate(plan)
      if (missing = REQUIREMENTS.select {|(k,_)| !plan.send(k) }).any?
        raise Error::InvalidPlan.missing_requirements(missing)
      else
        plan
      end
    end
  end
end
