module Suture::Util
  class ComparesResults
    def initialize(comparator)
      @comparator = comparator
    end

    def compare(expected, actual)
      if expected.errored?
        actual.value.kind_of?(expected.value.class) &&
          expected.value.message == actual.value.message
      else
        @comparator.call(expected.value, actual.value)
      end
    end
  end
end
