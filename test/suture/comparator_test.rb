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
      assert_equal true, @subject.call([:a, "b", 3], [:a, "b", 3])
      assert_equal false, @subject.call([:a, "b", 3], [:a, "b", 4])
      assert_equal true, @subject.call({:a => 5}, {:a => 5})
      assert_equal false, @subject.call({:a => 5}, {"a" => 5})
    end

    def test_object_type
      assert_equal true, @subject.call(Object.new, Object.new)
      assert_equal false, @subject.call(Object.new, {})
    end

    def test_active_record_on_the_merits
      assert_equal true, @subject.call(
        MyRecord.new(:foo => "bar"),
        MyRecord.new("foo" => "bar")
      )
      assert_equal false, @subject.call(
        MyRecord.new(:foo => "bar"),
        MyRecord.new("foo" => "baz")
      )
      assert_equal false, @subject.call(
        MyRecord.new(:foo => "bar"),
        MyRecord.new("foo" => "bar", :id => 4)
      )
      assert_equal false, @subject.call(MyRecord.new, MyOtherRecord.new)
    end

    def test_active_record_default_excluded_attrs
      assert_equal true, @subject.call(
        MyRecord.new(:foo => "bar", :updated_at => Time.new - 49),
        MyRecord.new(:foo => "bar", :updated_at => Time.new)
      )
      assert_equal true, @subject.call(
        MyRecord.new(:foo => "bar", :created_at => Time.new - 49),
        MyRecord.new(:foo => "bar", :created_at => Time.new)
      )
      assert_equal true, @subject.call(
        MyRecord.new(:created_at => Time.new - 49),
        MyRecord.new(:updated_at => Time.new)
      )
    end

    def test_active_record_custom_excluded_attrs
      @subject = Comparator.new(
        :active_record_excluded_attributes => [:biz, :baz]
      )

      assert_equal true, @subject.call(
        MyRecord.new(:biz => 1),
        MyRecord.new(:biz => 2)
      )
      assert_equal true, @subject.call(
        MyRecord.new(:biz => 2, :baz => 3),
        MyRecord.new(:biz => 2)
      )
      assert_equal false, @subject.call(
        MyRecord.new(:updated_at => Time.new - 49),
        MyRecord.new(:updated_at => Time.new)
      )
      assert_equal false, @subject.call(
        MyRecord.new(:created_at => Time.new - 49),
        MyRecord.new(:created_at => Time.new)
      )
    end

    module ::ActiveRecord
      class Base
        def initialize(attributes = {})
          @attributes = attributes
        end

        def attributes
          Hash[@attributes.map { |(k, v)|
            [k.to_s, v]
          }]
        end
      end
    end

    class MyRecord < ActiveRecord::Base
    end

    class MyOtherRecord < ActiveRecord::Base
    end

    class MyCustomType
      attr_reader :data
      def initialize(data)
        @data = data
        @id = __id__ # <-- will differ each time & thus fail a marshal check
      end

      def ==(other)
        @data == other.data
      end
    end

    def test_custom_type_overriding_equals_but_marshalling_differently
      assert_equal true, @subject.call(MyCustomType.new(4), MyCustomType.new(4))
      assert_equal false, @subject.call(MyCustomType.new(4), MyCustomType.new(8))
    end
  end
end
