require "fixtures/mathy"

class DevelopmentTest < Minitest::Test
  def test_add_is_no_opey
    assert_equal 14, Mathy.new.add(5, 9)
  end
end
