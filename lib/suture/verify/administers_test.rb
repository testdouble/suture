require "suture/util/compares_results"
require "suture/util/scalpel"
require "suture/value/result"

module Suture
  class AdministersTest
    def initialize
      @scalpel = Util::Scalpel.new
    end

    def administer(test_plan, observation)
      compares_results = Util::ComparesResults.new(test_plan.comparator)
      begin
        result = Value::Result.returned(@scalpel.cut(test_plan, :subject, observation.args))
        {
          :new_result => result,
          :passed => compares_results.compare(observation.result, result)
        }
      rescue StandardError => error
        if observation.result.errored?
          result = Value::Result.errored(error)
          {
            :new_result => result,
            :passed => compares_results.compare(observation.result, result)
          }
        else
          { :error => error, :passed => false }
        end
      end
    end
  end
end
