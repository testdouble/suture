require "suture/util/shuffle"

module Suture::Util
  class ShuffleTest < UnitTest
    def test_randomness_is_randomish_pre_2_0
      random = Random.new(202020)
      array = [1,2,3,4,5,6,7,8,9,10]

      result = Shuffle.shuffle(random, array)

      assert_equal [4, 5, 6, 7, 9, 8, 1, 10, 3, 2], result
      assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], array #<-- that it has not mutated
    end
  end
end

