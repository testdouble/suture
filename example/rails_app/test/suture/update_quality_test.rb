require "minitest/autorun"
require "suture"

require "application"
require "models/item"

class UpdateQualityTest < Minitest::Test
  def setup
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database  => "db/test.sqlite3"
    )
  end

  def test_old_update_quality_recordings
    Suture.verify :gilded_rose,
      :subject => lambda { |item|
        item.update_quality!
        item
      },
      :comparator => lambda { |recorded, actual|
        recorded.attributes.except("created_at", "updated_at") ==
          actual.attributes.except("created_at", "updated_at")
      }
  end
end
