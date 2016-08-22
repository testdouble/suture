require "suture/adapter/dictaphone"

module Suture::Surgeon
  class Observer
    def operate(plan)
      dictaphone = Suture::Adapter::Dictaphone.new(plan)
      invoke(plan).tap do |result|
        dictaphone.record(result)
      end
    end

    private

    def invoke(plan)
      if plan.args
        plan.old.call(*plan.args)
      else
        plan.old.call
      end
    end
  end
end

