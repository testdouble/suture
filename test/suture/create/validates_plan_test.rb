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

      assert_spacey_match "in order to differentiate recorded calls (if the code you're changing doesn't take arguments, you can set :args to `[]` but should probably consider creating a seam inside of it which can--consult the README for more advice)", error.message
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

      assert_spacey_match "The following options were invalid:", error.message
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
      plan = Value::Plan.new(:name => :pants, :old => ->{}, :args => [],
                             :record_calls => true, :database_path => nil)

      error = assert_raises(Error::InvalidPlan) { @subject.validate(plan) }

      assert_spacey_match "Suture isn't sure how to best handle the combination of options passed", error.message
      assert_spacey_match "* :record_calls is enabled, but :database_path is nil, so Suture doesn't know where to record calls to the seam.", error.message
    end

    def test_raise_when_record_calls_and_call_both_are_both_set
      plan = Value::Plan.new(:name => :pants, :old => ->{}, :args => [],
                             :record_calls => true, :database_path => true,
                             :call_both => true)

      error = assert_raises(Error::InvalidPlan) { @subject.validate(plan) }

      assert_spacey_match "* :record_calls & :call_both are both enabled and conflict with one another. :record_calls will only invoke the old code path (intended for characterization of the old code path and initial development of the new code path), whereas :call_both will invoke the new path and the old to compare their results after development of the new code path is initially complete (typically in a pre-production environment to validate the behavior of the new code path is consistent with the old). If you're still actively developing the new code path and need more recordings to feed Suture.verify, disable :call_both; otherwise, it's likely time to turn off :record_calls on this seam.", error.message
    end

    def test_raise_when_record_calls_and_call_old_on_error_are_both_set
      plan = Value::Plan.new(:name => :pants, :old => ->{}, :args => [],
                             :record_calls => true, :database_path => true,
                             :call_old_on_error => true)

      error = assert_raises(Error::InvalidPlan) { @subject.validate(plan) }

      assert_spacey_match "* :record_calls & :call_old_on_error are both enabled and conflict with one another. :record_calls will only invoke the old code path (intended for characterization of the old code path and initial development of the new code path), whereas :call_old_on_error will call the new code path unless an error is raised, in which case it will fall back on the old code path.", error.message
    end

    def test_raise_when_call_both_and_call_old_on_error_are_both_set
      plan = Value::Plan.new(:name => :pants, :old => ->{}, :args => [],
                             :call_both => true, :call_old_on_error => true)

      error = assert_raises(Error::InvalidPlan) { @subject.validate(plan) }

      assert_spacey_match "* :call_both & :call_old_on_error are both enabled and conflict with one another. :call_both is designed for pre-production environments and will call both the old and new code paths to compare their results, whereas :call_old_on_error is designed for production environments where it is safe to call the old code path in the event that the new code path fails unexpectedly", error.message
    end

  end
end
