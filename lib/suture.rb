require "suture/version"

require "suture/surgeon"
require "suture/value"

require "suture/builds_plan"
require "suture/chooses_surgeon"
require "suture/performs_surgery"

module Suture
  def self.create(name, options)
    plan = BuildsPlan.new.build(name, options)
    surgeon = ChoosesSurgeon.new.choose(plan)
    PerformsSurgery.new.perform(plan, surgeon)
  end
end
