module Suture::Surgeon
  class ObserverTest < Minitest::Test
    def setup
      @subject = Observer.new
    end

    def test_record_calls
      dictaphone = gimme_next(Suture::Adapter::Dictaphone)
      plan = Suture::Value::Plan.new(
        :name => :panda,
        :old => lambda {|arg1| "#{arg1} pants" },
        :args => [5]
      )

      result = @subject.operate(plan)

      assert_equal "5 pants", result
      verify!(dictaphone).initialize(plan)
      verify(dictaphone).record("5 pants")
    end
  end
end
