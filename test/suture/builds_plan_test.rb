module Suture
  class BuildsPlanTest < Minitest::Test
    def teardown
      ENV.delete_if { |(k,v)| k.start_with?("SUTURE_") }
      Suture.reset!
    end

    def test_defaults
      result = BuildsPlan.new.build(:foo)

      assert_equal "db/suture.sqlite3", result.database_path
      assert_kind_of Suture::Comparator, result.comparator
      assert_equal :foo, result.name
    end

    class Lol
      def compare(*args)
      end
    end

    def test_global_overrides
      Suture.config(:database_path => "other.db")
      Suture.config(:comparator => Lol.new)

      result = BuildsPlan.new.build(:foo)

      assert_equal "other.db", result.database_path
      assert_kind_of Lol, result.comparator
    end

    def test_build_without_env_vars
      some_callable = lambda { "hi" }
      some_new_callable = lambda { "hi" }
      some_args = [1,2,3]
      some_comparator = Lol.new

      result = BuildsPlan.new.build(:some_name, {
        :old => some_callable,
        :new => some_new_callable,
        :args => some_args,
        :record_calls => :panda,
        :comparator => some_comparator,
        :database_path => "blah.db"
      })

      assert_equal :some_name, result.name
      assert_equal some_callable, result.old
      assert_equal some_new_callable, result.new
      assert_equal some_args, result.args
      assert_equal true, result.record_calls
      assert_equal some_comparator, result.comparator
      assert_equal "blah.db", result.database_path
    end

    def test_build_with_env_vars
      ENV['SUTURE_NAME'] = 'bad name'
      ENV['SUTURE_RECORD_CALLS'] = 'trololol'
      ENV['SUTURE_OLD'] = 'a'
      ENV['SUTURE_NEW'] = 'b'
      ENV['SUTURE_ARGS'] = 'c'
      ENV['SUTURE_COMPARATOR'] = 'e'
      ENV['SUTURE_DATABASE_PATH'] = 'd'

      result = BuildsPlan.new.build(:a_name)

      assert_equal "d", result.database_path
      assert_equal true, result.record_calls
      # options that can't be set with ENV vars:
      assert_equal :a_name, result.name
      assert_equal nil, result.old
      assert_equal nil, result.new
      assert_equal nil, result.args
      assert_equal Suture::DEFAULT_OPTIONS[:comparator], result.comparator
    end

    def test_build_with_falsey_env_var
      ENV['SUTURE_RECORD_CALLS'] = nil

      result = BuildsPlan.new.build(:something)

      assert_equal false, result.record_calls
    end

    def test_build_with_false_string_env_var
      ENV['SUTURE_RECORD_CALLS'] = "false"

      result = BuildsPlan.new.build(:something)

      assert_equal false, result.record_calls
    end
  end
end
