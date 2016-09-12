require "suture/create/builds_plan"

module Suture
  class BuildsPlanTest < UnitTest
    def teardown
      super
      ENV.delete_if { |(k,v)| k.start_with?("SUTURE_") }
      Suture.reset!
    end

    def test_defaults
      result = BuildsPlan.new.build(:foo)

      assert_equal "db/suture.sqlite3", result.database_path
      assert_kind_of Suture::Comparator, result.comparator
      assert_equal false, result.call_both
      assert_equal false, result.dup_args
      assert_equal false, result.raise_on_result_mismatch
      assert_equal [], result.expected_error_types
      assert_equal false, result.disable
    end

    def test_global_overrides
      Suture.config(:database_path => "other.db")
      Suture.config(:comparator => :lol_compare)

      result = BuildsPlan.new.build(:foo)

      assert_equal "other.db", result.database_path
      assert_equal :lol_compare, result.comparator
    end

    def test_build_without_env_vars
      some_callable = lambda { "hi" }
      some_new_callable = lambda { "hi" }
      some_args = [1,2,3]
      some_comparator = :some_compare
      some_after_new = lambda {}
      some_after_old = lambda {}
      some_on_new_error = lambda {}
      some_on_old_error = lambda {}

      result = BuildsPlan.new.build(:some_name, {
        :old => some_callable,
        :new => some_new_callable,
        :args => some_args,
        :record_calls => :panda,
        :comparator => some_comparator,
        :database_path => "blah.db",
        :raise_on_result_mismatch => false,
        :after_new => some_after_new,
        :after_old => some_after_old,
        :on_new_error => some_on_new_error,
        :on_old_error => some_on_old_error,
        :expected_error_types => [ZeroDivisionError],
        :disable => true,
        :dup_args => true
      })

      assert_equal :some_name, result.name
      assert_equal some_callable, result.old
      assert_equal some_new_callable, result.new
      assert_equal some_args, result.args
      assert_equal true, result.record_calls
      assert_equal some_comparator, result.comparator
      assert_equal "blah.db", result.database_path
      assert_equal false, result.raise_on_result_mismatch
      assert_equal some_after_new, result.after_new
      assert_equal some_after_old, result.after_old
      assert_equal some_on_new_error, result.on_new_error
      assert_equal some_on_old_error, result.on_old_error
      assert_equal [ZeroDivisionError], result.expected_error_types
      assert_equal true, result.disable
      assert_equal true, result.dup_args
    end

    def test_build_with_env_vars
      ENV['SUTURE_NAME'] = 'bad name'
      ENV['SUTURE_RECORD_CALLS'] = 'trololol'
      ENV['SUTURE_OLD'] = 'a'
      ENV['SUTURE_NEW'] = 'b'
      ENV['SUTURE_ARGS'] = 'c'
      ENV['SUTURE_COMPARATOR'] = 'e'
      ENV['SUTURE_DATABASE_PATH'] = 'd'
      ENV['SUTURE_RAISE_ON_RESULT_MISMATCH'] = 'false'
      ENV['SUTURE_AFTER_OLD'] = 'f'
      ENV['SUTURE_AFTER_NEW'] = 'g'
      ENV['SUTURE_ON_NEW_ERROR'] = 'i'
      ENV['SUTURE_ON_OLD_ERROR'] = 'j'
      ENV['SUTURE_EXPECTED_ERROR_TYPES'] = 'h'
      ENV['SUTURE_DISABLE'] = 'yes'
      ENV['SUTURE_DUP_ARGS'] = 'yay'

      result = BuildsPlan.new.build(:a_name)

      assert_equal "d", result.database_path
      assert_equal true, result.record_calls
      # options that can't be set with ENV vars:
      assert_equal :a_name, result.name
      assert_equal nil, result.old
      assert_equal nil, result.new
      assert_equal nil, result.args
      assert_equal Suture::DEFAULT_OPTIONS[:comparator], result.comparator
      assert_equal false, result.raise_on_result_mismatch
      assert_equal nil, result.after_old
      assert_equal nil, result.after_new
      assert_equal nil, result.on_new_error
      assert_equal nil, result.on_old_error
      assert_equal [], result.expected_error_types
      assert_equal true, result.disable
      assert_equal true, result.dup_args
    end

    def test_build_with_falsey_env_var
      ENV['SUTURE_RECORD_CALLS'] = nil

      result = BuildsPlan.new.build(:something)

      assert_equal false, result.record_calls
      assert_equal false, result.raise_on_result_mismatch
    end

    def test_build_with_false_string_env_var
      ENV['SUTURE_RECORD_CALLS'] = "false"

      result = BuildsPlan.new.build(:something)

      assert_equal false, result.record_calls
    end
  end
end
