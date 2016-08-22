require "suture/adapter/dictaphone"
require "suture/value/test_results"
require "backports/random/implementation"

module Suture
  class TestsPatient
    def test(test_plan)
      experienced_failure_in_life = false
      Value::TestResults.new(build_test_cases(test_plan).map { |observation|
        if test_plan.fail_fast && experienced_failure_in_life
          {
            :observation => observation,
            :ran => false
          }
        else
          invoke(test_plan, observation).merge({
            :observation => observation,
            :ran => true
          }).tap { |r| experienced_failure_in_life = true unless r[:passed]}
        end
      })
    end

    private

    def build_test_cases(test_plan)
      dictaphone = Suture::Adapter::Dictaphone.new(test_plan)
      rows = dictaphone.play(test_plan.verify_only)
      if test_plan.random_seed
        rows.shuffle(:random => Random.new(test_plan.random_seed))
      else
        rows
      end
    end

    def invoke(test_plan, observation)
      {}.tap do |result|
        begin
          result[:new_result] = if observation.args
                                  test_plan.subject.call(*observation.args)
                                else
                                  test_plan.subject.call
                                end
          result[:passed] = test_plan.comparator.call(observation.result, result[:new_result])
        rescue StandardError => e
          result[:passed] = false
          result[:error] = e
        end
      end
    end
  end
end

