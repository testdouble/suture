require "suture/comparator"
require "suture/value/result"

module Suture::Util
  class ComparesResultsTest < UnitTest
    def setup
      super
      @subject = ComparesResults.new(Suture::Comparator.new)
    end

    def test_results_match
      expected = Suture::Value::Result.returned(5)
      actual = Suture::Value::Result.returned(5)

      result = @subject.compare(expected, actual)

      assert_equal true, result
    end

    def test_results_do_not_match
      expected = Suture::Value::Result.returned(5)
      actual = Suture::Value::Result.returned("5")

      result = @subject.compare(expected, actual)

      assert_equal false, result
    end

    def test_return_plus_error
      expected = Suture::Value::Result.errored(StandardError.new("hi"))
      actual = Suture::Value::Result.returned(StandardError.new("hi"))

      result = @subject.compare(expected, actual)

      assert_equal false, result
    end

    class SubZeroDivisionError < ZeroDivisionError
    end

    def test_error_same_class_and_message
      expected = Suture::Value::Result.errored(ZeroDivisionError.new("hi"))
      actual = Suture::Value::Result.errored(SubZeroDivisionError.new("hi"))

      result = @subject.compare(expected, actual)

      assert_equal true, result
    end

    def test_error_different_class
      expected = Suture::Value::Result.errored(ZeroDivisionError.new("hi"))
      actual = Suture::Value::Result.errored(StandardError.new("hi"))

      result = @subject.compare(expected, actual)

      assert_equal false, result
    end

    def test_error_different_message
      expected = Suture::Value::Result.errored(StandardError.new("hi"))
      actual = Suture::Value::Result.errored(StandardError.new("bye"))

      result = @subject.compare(expected, actual)

      assert_equal false, result
    end
  end
end
