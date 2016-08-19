module Suture
  class BuildsPlanTest < Minitest::Test
    def test_build_without_env_vars
      some_callable = ->{ "hi" }
      some_new_callable = ->{ "hi" }
      some_args = [1,2,3]

      result = BuildsPlan.new.build({
        :old => some_callable,
        :new => some_new_callable,
        :args => some_args,
        :record_calls => :panda
      })

      assert_equal some_callable, result.old
      assert_equal some_new_callable, result.new
      assert_equal some_args, result.args
      assert_equal true, result.record_calls
    end

    def test_build_with_env_vars
      ENV['SUTURE_RECORD_CALLS'] = 'trololol'
      ENV['SUTURE_OLD'] = 'a'
      ENV['SUTURE_NEW'] = 'b'
      ENV['SUTURE_ARGS'] = 'c'

      result = BuildsPlan.new.build

      assert_equal true, result.record_calls
      assert_equal nil, result.old
      assert_equal nil, result.new
      assert_equal nil, result.args

      ENV.delete('SUTURE_OLD')
      ENV.delete('SUTURE_NEW')
      ENV.delete('SUTURE_ARGS')
      ENV.delete('SUTURE_RECORD_CALLS')
    end

    def test_build_with_falsey_env_var
      ENV['SUTURE_RECORD_CALLS'] = nil

      result = BuildsPlan.new.build

      assert_equal false, result.record_calls

      ENV.delete('SUTURE_RECORD_CALLS')
    end
  end
end
