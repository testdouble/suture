module Suture::Util
  class NumbersTest < UnitTest
    def test_percent
      assert_equal Numbers.percent(12, 13), 92
    end
  end
end
