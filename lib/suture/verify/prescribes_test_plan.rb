require "suture/value/test_plan"
require "suture/util/env"

module Suture
  class PrescribesTestPlan
    UN_ENV_IABLE_OPTIONS = [:name, :subject, :comparator, :after_subject,
      :on_subject_error, :expected_error_types]

    def prescribe(name, options = {})
      Value::TestPlan.new(Suture.config
                          .merge(options)
                          .merge(:name => name)
                          .merge(Suture::Util::Env.to_map(UN_ENV_IABLE_OPTIONS)))
    end
  end
end
