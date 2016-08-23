require "suture/adapter/dictaphone"
require "suture/value/test_results"
require "suture/util/shuffle"
require "backports/1.9.2/random"

module Suture
  class TestsPatient
    def test(test_plan)
      experienced_failure_in_life = false
      test_cases = build_test_cases(test_plan)
      Value::TestResults.new(test_cases.each_with_index.map { |observation, i|
        if (test_plan.fail_fast && experienced_failure_in_life) ||
            (test_plan.call_limit && i >= test_plan.call_limit)
          {
            :observation => observation,
            :ran => false
          }
        else
          invoke(test_plan, observation).merge({
            :observation => observation,
            :ran => true
          }).tap { |r| experienced_failure_in_life = true unless r[:passed] }
        end
      })
    end

    private

    def build_test_cases(test_plan)
      dictaphone = Suture::Adapter::Dictaphone.new(test_plan)
      shuffle(
        dictaphone.play(test_plan.verify_only),
        test_plan.random_seed
      )
    end

    def shuffle(rows, random_seed)
      return rows unless random_seed
      Suture::Util::Shuffle.shuffle(Random.new(random_seed), rows)
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

