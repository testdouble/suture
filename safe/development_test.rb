require "sqlite3"

class DevelopmentTest < SafeTest
  def test_no_record_is_no_op
    result = Suture.create :add,
      :old => lambda {|c,d| c + d },
      :args => [5,9]

    assert_equal 14, result
  end

  def test_record_does_record
    dictaphone = Suture::Adapter::Dictaphone.new

    result = Suture.create :add,
      :old => lambda {|c,*d| c + d[0] + d[1] },
      :args => [1,2,3],
      :record_calls => true

    assert_equal 6, result
    observations = dictaphone.play(:add)
    assert_equal 1, observations.size
    observation = observations.first
    assert_equal 1, observation.id
    assert_equal :add, observation.name
    assert_equal [1,2,3], observation.args
    assert_equal 6, observation.result
  end
end
