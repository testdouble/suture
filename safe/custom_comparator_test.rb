require "date"

class CustomComparatorTest < SafeTest
  class MyType
    attr_reader :created_at
    def initialize
      @created_at = Time.new
    end
  end

  class CreatesMyType
    def call
      MyType.new
    end
  end

  def setup
    super
    @subject = CreatesMyType.new
  end

  def test_demonstrating_observation_conflict
    expected_error = assert_raises(Suture::Error::ObservationConflict) do
      2.times do
        # Without a custom comparator here, we'll raise ObservationConflict
        #   errors. (Reason being that the same inputs will yield differing
        #   created_at values on MyType objects)
        Suture.create(:time_goes_on, {
          :old => @subject,
          :record_calls => true
        })
      end
    end
    assert_match "At suture :time_goes_on with inputs `nil`", expected_error.message
  end

  def test_custom_comparator_that_succeeds
    2.times do
      # With a custom comparator, when the same callable+args is found in the DB,
      #   it'll run against this comparator and should be fine, since future
      #   instances will always be in the future.
      Suture.create(:time_goes_on, {
        :old => @subject,
        :record_calls => true,
        :comparator => lambda { |recorded, actual| recorded.created_at < actual.created_at }
      })
    end

    # This makes sense, because the recorded created_at will always be less.
    Suture.verify(:time_goes_on, {
      :subject => @subject,
      :comparator => lambda { |recorded, actual| recorded.created_at < actual.created_at }
    })
  end

  def test_custom_comparator_that_intentionally_fails
    # Since we're only calling it once, we don't have to worry about the conflict
    #   and don't need the custom comparator to avoid ObservationConflict errors
    Suture.create(:time_goes_on, {
      :old => @subject,
      :record_calls => true
    })

    # This will fail because the comparator is expecting greater than instead of
    #   less than
    assert_raises(Suture::Error::VerificationFailed) do
      Suture.verify(:time_goes_on, {
        :subject => @subject,
        :comparator => lambda { |recorded, actual| recorded.created_at > actual.created_at }
      })
    end
  end

end
