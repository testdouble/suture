class ProductionTest < SafeTest
  def test_fallback_on_error_with_error
    after_old_called = false
    after_new_called = false
    on_new_error_called = false
    result = Suture.create(:thing,
      :old => lambda { :old_result },
      :after_old => lambda { |*_args| after_old_called = true },
      :new => lambda { raise "Hell" },
      :after_new => lambda { |*_args| after_new_called = true },
      :on_new_error => lambda { |*_args| on_new_error_called = true },
      :args => [],
      :fallback_on_error => true)

    assert_equal :old_result, result
    assert_equal true, after_old_called
    assert_equal false, after_new_called # <-- seems wrong to call after on error
    assert_equal true, on_new_error_called
  end

  def test_fallback_on_error_without_error
    old_called = false

    result = Suture.create(:thing,
      :old => lambda { old_called = true; :old_result },
      :new => lambda { :new_result },
      :args => [],
      :fallback_on_error => true)

    assert_equal :new_result, result
    assert_equal false, old_called
  end

  def test_fallback_on_error_but_disabled_it
    called_new = false

    result = Suture.create(:thing,
      :old => lambda { :old_result },
      :new => lambda { called_new = true; raise "HELL" },
      :args => [],
      :fallback_on_error => true,
      :disable => true)

    assert_equal :old_result, result
    assert_equal false, called_new
  end
end
