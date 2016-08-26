module Suture
  class ConfigTest < Minitest::Test
    def setup
      super
      Suture.config_reset!
    end

    def test_config_default
      assert_equal Suture::DEFAULT_OPTIONS, Suture.config
    end

    def test_config_override
      initial = Suture::DEFAULT_OPTIONS

      result = Suture.config({:pants => true})

      expected = Suture::DEFAULT_OPTIONS.merge(:pants => true)
      assert_equal expected, result
      assert_equal expected, Suture.config
    end

    def test_config_reset!
      Suture.config(:foo => "bar")

      result = Suture.config_reset!

      assert_equal Suture::DEFAULT_OPTIONS, result
    end
  end
end
