require "fixtures/calculator"

class VerifyTest < SafeTest
  def setup
    super
    ENV["SUTURE_RECORD_CALLS"] = "true"
    @subject = Calculator.new
  end

  def test_calculator_add_verify_on_old
    @subject.add(1,2)
    @subject.add(3,4)

    Suture.verify(:add, {
      :subject => @subject.method(:old_add)
    })
  end

  def test_calculator_add_verify_on_new
    @subject.add(1,2)
    @subject.add(3,4)

    assert_raises(Suture::Error::VerificationFailed) {
      Suture.verify(:add, {
        :subject => @subject.method(:broken_add)
      })
    }
  end

  def test_verify_only_shows_just_one_failure_instead_of_two
    @subject.add(1,2)
    @subject.add(3,4)

    expected_error = assert_raises(Suture::Error::VerificationFailed) {
      Suture.verify(:add, {
        :subject => @subject.method(:really_broken_add),
        :verify_only => 2
      })
    }
    assert_match "- Failed........1", expected_error.message
    assert_match "- Total calls...1", expected_error.message
  end

  def test_fail_fast_disabled
    @subject.add(1,2)
    @subject.add(3,4)
    @subject.add(5,6)

    error = assert_raises(Suture::Error::VerificationFailed) {
      Suture.verify(:add, {
        :subject => @subject.method(:broken_add),
        :fail_fast => false
      })
    }
    assert_match "- Failed........2", error.message
    assert_match "- Skipped.......0", error.message
  end

  def test_fail_fast_enabled
    @subject.add(1,2)
    @subject.add(3,4)
    @subject.add(5,6)

    error = assert_raises(Suture::Error::VerificationFailed) {
      Suture.verify(:add, {
        :subject => @subject.method(:broken_add),
        :fail_fast => true
      })
    }
    assert_match "- Failed........1", error.message
    assert_match "- Skipped.......1", error.message
  end
end
