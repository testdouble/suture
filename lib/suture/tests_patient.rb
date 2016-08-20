require "suture/adapter/dictaphone"

module Suture
  class TestsPatient
    def test(test_plan)
      dictaphone = Suture::Adapter::Dictaphone.new(test_plan)
      experienced_failure_in_life = false
      Value::TestResults.new(dictaphone.play(test_plan.name).map { |observation|
        if test_plan.fail_fast && experienced_failure_in_life
          {
            :observation => observation,
            :passed => nil,
            :ran => false
          }
        else
          {
            :observation => observation,
            # TODO: Comparators go here:
            :passed => test_plan.subject.call(*observation.args) == observation.result,
            :ran => true
          }.tap { |r| experienced_failure_in_life = true unless r[:passed]}
        end
      })
    end
  end
end

