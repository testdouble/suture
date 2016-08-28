require "suture/util/scalpel"
require "suture/adapter/dictaphone"

module Suture::Surgeon
  class Observer
    def operate(plan)
      dictaphone = Suture::Adapter::Dictaphone.new(plan)
      Suture::Util::Scalpel.new.cut(plan, :old).tap do |result|
        dictaphone.record(result)
      end
    end
  end
end

