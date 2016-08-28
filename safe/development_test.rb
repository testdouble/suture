require "suture/adapter/dictaphone"

class DevelopmentTest < SafeTest
  def test_no_record_is_no_op
    called_after_old = false
    result = Suture.create :add,
      :old => lambda {|c,d| c + d },
      :args => [5,9],
      :after_old => lambda { |*args| called_after_old = true }

    assert_equal 14, result
    assert_equal true, called_after_old
  end

  def test_record_does_record
    called_after_old = false
    dictaphone = Suture::Adapter::Dictaphone.new(Suture::BuildsPlan.new.build(:add))

    result = Suture.create :add,
      :old => lambda {|c,*d| c + d[0] + d[1] },
      :args => [1,2,3],
      :record_calls => true,
      :after_old => lambda { |*args| called_after_old = true }

    assert_equal 6, result
    observations = dictaphone.play
    assert_equal 1, observations.size
    observation = observations.first
    assert_equal 1, observation.id
    assert_equal :add, observation.name
    assert_equal [1,2,3], observation.args
    assert_equal 6, observation.result
    assert_equal true, called_after_old
  end

  def test_record_dumps_args_prior_to_mutation
    dictaphone = Suture::Adapter::Dictaphone.new(Suture::BuildsPlan.new.build(:add))

    result = Suture.create(:add, {
      :old => lambda {|h| h["key ##{h.size+1}"] = "troll"; h},
      :args => [{:yo => "ho"}],
      :record_calls => true
    })

    assert_equal({:yo => "ho", "key #2" => "troll"}, result)
    observations = dictaphone.play
    assert_equal 1, observations.size
    observation = observations.first
    assert_equal [{:yo => "ho"}], observation.args
    assert_equal({:yo => "ho", "key #2" => "troll"}, observation.result)
  end
end
