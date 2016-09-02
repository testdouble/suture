class StagingTest < SafeTest
  def test_call_both
    old_called = false
    new_called = true

    result = Suture.create(:thing,
      :old => lambda { |a, b| old_called = true; a * b },
      :new => lambda { |a, b| new_called = true; a + b },
      :args => [3, 5],
      :comparator => lambda { |old, new| old == 15 && new == 8 },
      :call_both => true
    )

    assert_equal 8, result
    assert_equal true, old_called
    assert_equal true, new_called
  end

  class Stateful
    attr_accessor :number
    def initialize(number)
      @number = number
    end
  end
  def test_call_both_and_dup_args
    old_called = false
    new_called = true

    result = Suture.create(:thing,
      :old => lambda { |a, b|
        old_called = true;
        (a.number + b).tap { |result| a.number = result }
      },
      :new => lambda { |a, b|
        new_called = true;
        (a.number + b).tap { |result| a.number = result }
      },
      :args => [Stateful.new(3), 5],
      :call_both => true,
      :dup_args => true
    )

    assert_equal 8, result
    assert_equal true, old_called
    assert_equal true, new_called
  end
end
