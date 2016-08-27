require "suture/create/builds_plan"
require "suture/create/validates_plan"
require "suture/create/chooses_surgeon"
require "suture/create/performs_surgery"

module Suture
  def self.create(name, options)
    plan = ValidatesPlan.new.validate(BuildsPlan.new.build(name, options))
    surgeon = ChoosesSurgeon.new.choose(plan)
    PerformsSurgery.new.perform(plan, surgeon)
  end
end
