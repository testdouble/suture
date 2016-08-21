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
end
