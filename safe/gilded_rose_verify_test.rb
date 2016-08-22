require_relative "helper"
require_relative "fixtures/gilded_rose"

class GildedRoseVerifyTest < SafeTest
  def setup
    super
    record_calls_of_the_original_code!
  end

  # This test verifies that when we play back what we just recorded against
  # the very same method, we get the same results. This ensures nothing is
  # being lost in persisting/extracting or comparing the items
  #
  # To run this test in isolation:
  #  bundle exec rake safe TESTOPTS="--name=test_gilded_rose_old"
  #
  def test_gilded_rose_old
    Suture.verify(:gilded_rose, {
      :subject => lambda { |items| GildedRose.old_update_quality(items); items },
      :fail_fast => true
    })
  end

  # This test verifies that @jimweirich's published solution to the Gilded Rose
  #   kata behaves the same way as the original code path. It will start by
  #   recording the original code then verify the recorded entries against the
  #   new code
  #
  # In this case we set `fail_fast` to false, because if we'd been using this
  #   Suture.verify to check our progress during a refactor, we'd want to see the
  #   total numbers of passed/failed, not just the first failure.
  #
  # To run this test in isolation:
  #  bundle exec rake safe TESTOPTS="--name=test_gilded_rose_new"
  #
  def test_gilded_rose_new
    Suture.verify(:gilded_rose, {
      :subject => lambda { |items| GildedRose.new_update_quality(items); items },
      :fail_fast => false
    })
  end

  private

  # Pretend the user wrote a little script to capture recordings
  #   or perhaps they just ran their server and then indirectly invoked it
  #   a bunch.
  # Since this is a test we're going to be intentionally contrived here instead
  def record_calls_of_the_original_code!
    ENV["SUTURE_RECORD_CALLS"] = "true"
    items = create_a_bunch_of_items
    100.times do
      GildedRose.update_quality(items)
    end
    ENV.delete("SUTURE_RECORD_CALLS")
  end

  def create_a_bunch_of_items
    [
      GildedRose::Item.new("NORMAL ITEM", 5, 10),
      GildedRose::Item.new("Aged Brie", 3, 10),
      GildedRose::Item.new("+5 Dexterity Vest", 10, 20),
      GildedRose::Item.new("Aged Brie", 2, 0),
      GildedRose::Item.new("Elixir of the Mongoose", 5, 7),
      GildedRose::Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
      GildedRose::Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20)
    ]
  end

end
