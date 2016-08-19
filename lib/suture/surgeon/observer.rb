require "suture/adapter/dictaphone"

module Suture::Surgeon
  class Observer
    def initialize
      @dictaphone = Suture::Adapter::Dictaphone.new
    end

    def operate(plan)
      plan.old.call(*plan.args).tap do |result|
        @dictaphone.record(plan.name, plan.args, result)
      end
    end
  end
end

