require "suture/create/builds_plan"
require "suture/create/validates_plan"
require "suture/create/chooses_surgeon"
require "suture/create/performs_surgery"

module Suture
  class CreateTest < UnitTest
    def test_create
      builds_plan = gimme_next(Suture::BuildsPlan)
      validates_plan = gimme_next(Suture::ValidatesPlan)
      chooses_surgeon = gimme_next(Suture::ChoosesSurgeon)
      performs_surgery = gimme_next(Suture::PerformsSurgery)
      options = {:foo => :bar}
      plan = Suture::Value::Plan.new
      validated_plan = Suture::Value::Plan.new
      surgeon = Suture::Surgeon::NoOp.new
      give(builds_plan).build(:thing, options) { plan }
      give(validates_plan).validate(plan) { validated_plan }
      give(chooses_surgeon).choose(validated_plan) { surgeon }
      give(performs_surgery).perform(validated_plan, surgeon) { :pants }

      result = Suture.create(:thing, options)

      assert_equal :pants, result
    end
  end
end
