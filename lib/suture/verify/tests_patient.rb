require "suture/adapter/log"
require "suture/adapter/dictaphone"
require "suture/value/test_results"
require "suture/util/scalpel"
require "suture/util/shuffle"
require "suture/util/timer"
require "backports/1.9.2/random"

module Suture
  class TestsPatient
    include Suture::Adapter::Log

    def initialize
      @scalpel = Suture::Util::Scalpel.new
    end

    def test(test_plan)
      experienced_failure_in_life = false
      timer = Suture::Util::Timer.new(test_plan.time_limit) unless test_plan.time_limit.nil?
      test_cases = build_test_cases(test_plan)
      Value::TestResults.new(test_cases.each_with_index.map { |observation, i|
        if should_skip?(test_plan, experienced_failure_in_life, i, timer)
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

    def should_skip?(test_plan, failed_fast, call_count, timer)
      (test_plan.fail_fast && failed_fast) ||
        (test_plan.call_limit && call_count >= test_plan.call_limit) ||
        (timer && timer.time_up?)
    end

    def build_test_cases(test_plan)
      dictaphone = Suture::Adapter::Dictaphone.new(test_plan)
      shuffle(
        dictaphone.play(test_plan.verify_only),
        test_plan.random_seed
      ).tap do |test_cases|
        next if test_cases.size > 0
        log_warn <<-MSG.gsub(/^ {10}/,'')
          Suture.verify found no recorded calls for seam #{test_plan.name.inspect}.
          As a result, verify will have no effect and cannot provide any assurance
          that the subject is working as expected.
        MSG
      end
    end

    def shuffle(rows, random_seed)
      return rows unless random_seed
      Suture::Util::Shuffle.shuffle(Random.new(random_seed), rows)
    end

    def invoke(test_plan, observation)
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

