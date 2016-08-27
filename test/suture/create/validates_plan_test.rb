require "suture/create/validates_plan"

require "support/assertions"

module Suture
  class ValidatesPlanTest < Minitest::Test
    include Support::Assertions

    def setup
      super
      @subject = ValidatesPlan.new
    end

    def test_valid_plan
      plan = Value::Plan.new(:name => :pants, :old => ->{}, :args => [])

      result = @subject.validate(plan)

      assert_equal plan, result
    end

    # 1. Required fields missing

    def test_raise_when_no_name
      plan = Value::Plan.new(:old => ->{}, :args => [])

      error = assert_raises(Error::InvalidPlan) { @subject.validate(plan) }

      assert_spacey_match "options passed to `Suture.create` were invalid", error.message
      assert_spacey_match "The following options are required:", error.message
      assert_spacey_match "* :name - in order to identify recorded calls", error.message
    end

    def test_raise_when_no_code_path
      plan = Value::Plan.new(:name => :pants, :args => [])

      error = assert_raises(Error::InvalidPlan) { @subject.validate(plan) }

      assert_spacey_match "* :old - in order to call the legacy code path (must respond to `:call`)", error.message
    end

    def test_raise_when_args_are_not_set
      plan = Value::Plan.new(:name => :pants, :old => ->{})

      error = assert_raises(Error::InvalidPlan) { @subject.validate(plan) }

      assert_spacey_match "* :args - in order to differentiate recorded calls (if the code you're changing doesn't take arguments, consider creating a seam inside of it which can--consult the README for more advice)", error.message
    end

    def test_raise_with_multiple_missing_required_params
      plan = Value::Plan.new()

      error = assert_raises(Error::InvalidPlan) { @subject.validate(plan) }

      assert_spacey_match "* :name", error.message
      assert_spacey_match "* :old", error.message
      assert_spacey_match "* :args", error.message
    end

    # 2. Arguments are invalid

    def test_raise_when_name_is_longer_than_255
      plan = Value::Plan.new(:name => "a" * 256, :old => ->{}, :args => [])

      error = assert_raises(Error::InvalidPlan) { @subject.validate(plan) }

      assert_spacey_match "* :name - must be less than 256 characters", error.message
    end

    def test_raise_when_old_is_not_callable
      plan = Value::Plan.new(:name => :pants, :old => Object, :args => [])

      error = assert_raises(Error::InvalidPlan) { @subject.validate(plan) }

      assert_spacey_match "* :old - must respond to `call` (e.g. `dog.method(:bark)` or `->(*args){ dog.bark(*args) }`)", error.message
    end

    def test_raise_when_new_is_defined_and_not_callable
      plan = Value::Plan.new(:name => :a, :old => ->{}, :args => [], :new => "")

      error = assert_raises(Error::InvalidPlan) { @subject.validate(plan) }

      assert_spacey_match "* :new - must respond to `call` (e.g. `dog.method(:bark)` or `->(*args){ dog.bark(*args) }`)", error.message
    end

    def test_raise_when_comparator_is_defined_and_not_callable
      plan = Value::Plan.new(:name => :a, :old => ->{}, :args => [],
                             :comparator => "Object#method")

      error = assert_raises(Error::InvalidPlan) { @subject.validate(plan) }

      assert_spacey_match "* :comparator - must respond to `call` (e.g. `MyComparator.new` or `->(recorded, actual) { recorded == actual }`)", error.message
    end

    # 3. Invalid combinations

    def test_raise_when_record_calls_and_nil_database_path
    end

    def test_raise_when_record_calls_and_run_both_are_both_set
    end

    def test_raise_when_record_calls_and_fallback_on_error_are_both_set
    end

    def test_raise_when_run_both_and_fallback_on_error_are_both_set
    end

  end
end
