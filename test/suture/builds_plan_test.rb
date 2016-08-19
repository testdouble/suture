require "suture/builds_plan"

class BuildsPlanTest < Minitest::Test
  def test_build
    some_callable = ->{ "hi" }
    some_args = [1,2,3]

    result = Suture::BuildsPlan.new.build({
      :old => some_callable,
      :args => some_args
    })

    assert_equal some_callable, result.old
    assert_equal some_args, result.args
  end
end
