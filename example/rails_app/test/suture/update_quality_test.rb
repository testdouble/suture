require "minitest/autorun"
require "suture"

require "application"
require "models/item"
require "quality_updater"

class UpdateQualityTest < Minitest::Test
  def setup
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database => "db/test.sqlite3"
    )
  end

  def test_old_update_quality_recordings
    Suture.verify :gilded_rose,
      :subject => lambda { |item|
        item.update_quality!
        item
      }
  end

  def test_new_update_quality_against_oldrecordings
    quality_updater = QualityUpdater.new
    Suture.verify :gilded_rose,
      :subject => lambda { |item|
        quality_updater.update(item)
        item
      }
  end
end
