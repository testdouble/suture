module Suture::Value
  class ResultTest < UnitTest
    def test_equality
      assert_equal Result.returned("a"), Result.returned("a")
      assert_equal Result.errored("a"), Result.errored("a")
      refute_equal Result.returned("a"), Result.returned("b")
      refute_equal Result.errored("a"), Result.errored("b")
      refute_equal Result.returned("a"), Result.errored("a")
    end

    def test_hashability
      hash = { Result.returned("a") => Result.returned("b") }

      hash[Result.returned("a")] = Result.returned("c")

      assert_equal 1, hash.size
      assert_equal Result.returned("c"), hash[Result.returned("a")]
    end
  end
end
