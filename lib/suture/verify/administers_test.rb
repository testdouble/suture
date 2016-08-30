require "suture/util/scalpel"

module Suture
  class AdministersTest
    def initialize
      @scalpel = Suture::Util::Scalpel.new
    end

    def administer(test_plan, observation)
      begin
        result = Suture::Value::Result.returned(@scalpel.cut(test_plan, :subject, observation.args))
        {
          :new_result => result,
          :passed => test_plan.comparator.call(observation.result.value, result.value)
        }
      rescue StandardError => e
        { :passed => false, :error => e }
      end
    end
  end
end
