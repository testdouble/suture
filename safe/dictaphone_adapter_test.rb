require "suture/adapter/dictaphone"

class DictaphoneAdapterTest < SafeTest
  def test_will_fail_on_identical_observation_with_different_result
    subject = Suture::Adapter::Dictaphone.new

    subject.record(:foo, [1,2,3], :bar)

    e = assert_raises(Suture::Error::ObservationConflict) {
      subject.record(:foo, [1,2,3], :baz)
    }
    expected_message = <<-MSG.gsub(/^\s{6}/,'')
      At suture :foo with inputs `[1, 2, 3]`, the newly-observed return value `:baz`
      conflicts with previously recorded return value `:bar`.

      That's not good! Here are a few ideas of what may have happened:

      1. The old code path may have a side effect that results in different
         return values. If it's possible, to create the suture at a point after
         this side effect. Otherwise, read on.

      2. Either environmental differents (e.g. system time resulting in a
         different timestamp) or side effects (e.g. saving to a database
         resulting in a different GUID value) mean that Suture is detecting two
         different results for the same inputs. This can be worked around by
         providing a custom comparator for the two values nearest common
         ancestor type. Comparator support is tracked here:
           https://github.com/testdouble/suture/issues/14

      3. If neither of the above are true, it's possible that the old code path
         was changed while still in the early stage of recording characterization
         calls (presumably by mistake). If such a change may have occurred in
         error, check your git history. Otherwise, perhaps you `record_calls` is
         accidentally still enabled and should be turned off for this suture
         (either with SUTURE_RECORD_CALLS=false or :record_calls => false).

      4. If the old recording was made in error, then you may want to delete it
         Deletion support via the Suture API is tracked here:
           https://github.com/testdouble/suture/issues/10

    MSG
    assert_equal expected_message, e.message
  end

  def test_will_succeed_on_identical_observation_with_identical_result
    subject = Suture::Adapter::Dictaphone.new

    subject.record(:foo, [1,2,3], :bar)
    subject.record(:foo, [1,2,3], :bar)
  end
end
