require "suture/adapter/dictaphone"

class DictaphoneAdapterTest < SafeTest
  def test_will_fail_on_identical_observation_with_different_result
    subject = Suture::Adapter::Dictaphone.new(Suture::BuildsPlan.new.build(:foo,
      :args => [1,2,3]
    ))

    subject.record(:bar)

    e = assert_raises(Suture::Error::ObservationConflict) {
      subject.record(:baz)
    }
    expected_message = <<-MSG.gsub(/^ {6}/,'')
      At seam :foo, we just recorded a duplicate call, but the same arguments
      resulted in a different output. Read on for details:

      Arguments: ```
        [1, 2, 3]
      ```
      Previously-observed return value: ```
        :bar
      ```

      Newly-observed return value: ```
        :baz
      ```

      That's not good! Here are a few ideas of what may have happened:

      1. The old code path may have a side effect that results in different
         return values. If it's possible, to create the suture at a point after
         this side effect. Otherwise, read on.

      2. Either environmental differents (e.g. system time resulting in a
         different timestamp) or side effects (e.g. saving to a database
         resulting in a different GUID value) mean that Suture is detecting two
         different results for the same inputs. This can be worked around by
         providing a custom comparator to Suture. For more info, see the README:

           https://github.com/testdouble/suture#creating-a-custom-comparator

      3. If neither of the above are true, it's possible that the old code path
         was changed while still in the early stage of recording characterization
         calls (presumably by mistake). If such a change may have occurred in
         error, check your git history. Otherwise, perhaps you `record_calls` is
         accidentally still enabled and should be turned off for this seam
         (either with SUTURE_RECORD_CALLS=false or :record_calls => false).

      4. If, after exhausting the possibilities above, you're pretty sure the
         recorded result is in error, you can delete it from Suture's database
         with:

           Suture.delete(1)
    MSG
    assert_equal expected_message, e.message
  end

  def test_will_succeed_on_identical_observation_with_identical_result
    subject = Suture::Adapter::Dictaphone.new(Suture::BuildsPlan.new.build(:foo,
      :args => [1,2,3]
    ))

    subject.record(:bar)
    subject.record(:bar)
  end

  def test_will_support_playing_just_one_row
    Suture::Adapter::Dictaphone.new(Suture::BuildsPlan.new.build(:foo, {
      :args => [:pants]
    })).record(:shirt)
    Suture::Adapter::Dictaphone.new(Suture::BuildsPlan.new.build(:foo, {
      :args => [:panda]
    })).record(:bamboo)

    rows = Suture::Adapter::Dictaphone.new(Suture::BuildsPlan.new.build(:foo, {
      :verify_only => 1
    })).play(1) # <-- where one assumes 1 is the ID of pants
    assert_equal 1, rows.size
    assert_equal [:pants], rows.first.args
    assert_equal :shirt, rows.first.result
  end
end
