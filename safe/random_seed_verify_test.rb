require "suture/error/verification_failed"

class RandomSeedVerifyTest < SafeTest
  class MyOrderMatters
    def initialize
      @call_count = 0
    end

    def call(*args_i_will_ignore)
      @call_count += 1
    end
  end

  def record_my_order_matters(order_matters, input)
    Suture.create(:order_matters, {
      :old => order_matters,
      :args => [input],
      :record_calls => true
    })
  end

  def test_blows_up_in_one_order
    order_matters = MyOrderMatters.new
    record_my_order_matters(order_matters, :lol)
    record_my_order_matters(order_matters, :pants)

    expected_error = assert_raises(Suture::Error::VerificationFailed) {
      Suture.verify(:order_matters, {
        :subject => MyOrderMatters.new,
        :fail_fast => false,
        :random_seed => 19218
      })
    }
    assert_match ":random_seed => 1921", expected_error.message
  end

  def test_does_not_blow_up_in_another_order
    order_matters = MyOrderMatters.new
    record_my_order_matters(order_matters, :lol)
    record_my_order_matters(order_matters, :pants)

    Suture.verify(:order_matters, {
      :subject => MyOrderMatters.new,
      :fail_fast => false,
      :random_seed => 73247
    })
  end

  def test_can_be_run_in_select_order
    order_matters = MyOrderMatters.new
    record_my_order_matters(order_matters, :lol)
    record_my_order_matters(order_matters, :pants)
    record_my_order_matters(order_matters, :stuff)
    record_my_order_matters(order_matters, :heheh)

    expected_error = assert_raises(Suture::Error::VerificationFailed) {
      Suture.verify(:order_matters, {
        :subject => lambda { |input| MyOrderMatters.new(input) }, #<-- newing each time will cause it to fail
        :fail_fast => false,
        :random_seed => nil
      })
    }
    assert_match ":random_seed => nil # (insertion order)", expected_error.message
  end
end
