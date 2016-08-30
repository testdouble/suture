require "suture/util/scalpel"

module Suture
  class AdministersTest
    def initialize
      @scalpel = Suture::Util::Scalpel.new
    end

    def administer(test_plan, observation)
      {}.tap do |result|
        begin
          result[:new_result] = @scalpel.cut(test_plan, :subject, observation.args)
          result[:passed] = test_plan.comparator.call(observation.result, result[:new_result])
        rescue StandardError => e
          result[:passed] = false
          result[:error] = e
        end
      end
    end
  end
end
