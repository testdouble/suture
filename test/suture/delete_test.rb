module Suture
  class DeleteTest < Minitest::Test
    def test_delete
      builds_plan = gimme_next(BuildsPlan)
      dictaphone = gimme_next(Adapter::Dictaphone)
      plan = Value::Plan.new
      give(builds_plan).build(anything, :some_options) { plan }

      Suture.delete(129, :some_options)

      verify!(dictaphone).initialize(plan)
      verify(dictaphone).delete(129)
    end
  end
end
