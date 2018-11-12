require "minitest/autorun"
require "suture"

require "application"
require "models/item"
require "quality_updater"

class SutureComparatorTest < Minitest::Test
  def setup
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database => "db/test.sqlite3"
    )

    @subject = Suture::Comparator.new
  end

  def test_some_items
    assert_equal true, @subject.call(Item.new, Item.new)
    assert_equal true, @subject.call(Item.new(:name => "Hi"), Item.new(:name => "Hi"))
    assert_equal false, @subject.call(Item.new(:name => "Hi"), Item.new(:name => "Bye"))
  end

  def test_default_ar_comparison_ignores_timestamps_includes_ids
    item1 = Item.create!(:quality => 5)
    item2 = Item.find(item1.id).tap { |i|
      i.update_attributes!(:quality => 4)
      i.update_attributes!(:quality => 5)
    }
    item3 = Item.create!(:quality => 5)

    assert_equal true, @subject.call(item1, item2)
    assert_equal false, @subject.call(item1, item3), "ids differ"
    assert_equal false, @subject.call(item2, item3), "ids differ"

    [item1, item2, item3].each { |i| i.id = nil }

    assert_equal true, @subject.call(item1, item2)
    assert_equal true, @subject.call(item1, item3)
    assert_equal true, @subject.call(item2, item3)
  end

  def test_custom_ar_comparison_ignoring_ids_too
    @subject = Suture::Comparator.new(
      :active_record_excluded_attributes => [:created_at, :updated_at, :id]
    )

    item1 = Item.create!(:quality => 5)
    item2 = Item.find(item1.id).tap { |i|
      i.update_attributes!(:quality => 4)
      i.update_attributes!(:quality => 5)
    }
    item3 = Item.create!(:quality => 5)

    assert_equal true, @subject.call(item1, item3)
    assert_equal true, @subject.call(item1, item2)
    assert_equal true, @subject.call(item2, item3)
  end
end
