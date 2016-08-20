require "suture/adapter/dictaphone"

module Suture::Surgeon
  class Observer
    def operate(plan)
      dictaphone = Suture::Adapter::Dictaphone.new(plan)
      plan.old.call(*plan.args).tap do |result|
        dictaphone.record(result)
      end
    end
  end
end

