require "suture/delete"

module Suture
  class DeleteTest < UnitTest
    def test_delete!
      builds_plan = gimme_next(BuildsPlan)
      dictaphone = gimme_next(Adapter::Dictaphone)
      plan = Value::Plan.new
      give(builds_plan).build(anything, :some_options) { plan }

      Suture.delete!(129, :some_options)

      verify!(dictaphone).initialize(plan)
      verify(dictaphone).delete_by_id!(129)
    end

    def test_delete_all!
      builds_plan = gimme_next(BuildsPlan)
      dictaphone = gimme_next(Adapter::Dictaphone)
      plan = Value::Plan.new
      give(builds_plan).build(anything, :some_options) { plan }

      Suture.delete_all!(:foo, :some_options)

      verify!(dictaphone).initialize(plan)
      verify(dictaphone).delete_by_name!(:foo)
    end
  end
end
