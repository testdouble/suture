require "suture/util/scalpel"
require "suture/adapter/dictaphone"

module Suture::Surgeon
  class Observer
    def operate(plan)
      dictaphone = Suture::Adapter::Dictaphone.new(plan)
      begin
        Suture::Util::Scalpel.new.cut(plan, :old).tap do |result|
          dictaphone.record(result)
        end
      rescue => error
        if plan.expected_error_types.any? { |e| error.is_a?(e) }
          dictaphone.record_error(error)
        end
        raise error
      end
    end
  end
end
