module Suture
  class ComparatorTest < UnitTest
    def setup
      super
      @subject = Comparator.new
    end

    def test_simple_types
      assert_equal true, @subject.call(42, 42)
      assert_equal false, @subject.call(13, 37)
      assert_equal true, @subject.call("abc", "abc")
      assert_equal false, @subject.call("abc", "cba")
      assert_equal false, @subject.call("abc", :abc)
      assert_equal true, @subject.call(:abc, :abc)
      assert_equal false, @subject.call(:abc, :abcd)
      assert_equal true, @subject.call([:a, 'b', 3], [:a, 'b', 3])
      assert_equal false, @subject.call([:a, 'b', 3], [:a, 'b', 4])
      assert_equal true, @subject.call({:a => 5}, {:a => 5})
      assert_equal false, @subject.call({:a => 5}, {"a" => 5})
    end

    def test_object_type
      assert_equal true, @subject.call(Object.new, Object.new)
      assert_equal false, @subject.call(Object.new, Hash.new)
    end

    class MyCustomType
      attr_reader :data
      def initialize(data)
        @data = data
        @id = __id__ #<-- will differ each time & thus fail a marshal check
      end

      def ==(other_thing)
        @data == other_thing.data
      end
    end

    def test_custom_type_overriding_equals_but_marshalling_differently
      assert_equal true, @subject.call(MyCustomType.new(4), MyCustomType.new(4))
      assert_equal false, @subject.call(MyCustomType.new(4), MyCustomType.new(8))
    end
  end
end

