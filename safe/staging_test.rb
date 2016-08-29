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
end
