module Suture::Surgeon
  class ObserverTest < Minitest::Test
    def setup
      @dictaphone = gimme_next(Suture::Adapter::Dictaphone)

      @subject = Observer.new
    end

    def test_record_calls
      plan = Suture::Value::Plan.new(
        :name => :panda,
        :old => lambda {|*args| :pants },
        :args => [:arg1]
      )

      result = @subject.operate(plan)

      assert_equal :pants, result
      verify(@dictaphone).record(:panda, [:arg1], :pants)
    end
  end
end
