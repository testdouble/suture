require "suture/adapter/dictaphone"

module Suture
  class TestsPatient
    def test(test_plan)
      dictaphone = Suture::Adapter::Dictaphone.new(test_plan)
      Value::TestResults.new(dictaphone.play(test_plan.name).map { |observation|
        begin
          # TODO comparators go here
          passed = test_plan.subject.call(*observation.args) == observation.result
        end
        {
          :observation => observation,
          :passed => passed,
          :ran => true
        }
      })
    end
  end
end

