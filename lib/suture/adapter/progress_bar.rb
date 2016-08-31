require "bar-of-progress"

module Suture::Adapter
  class ProgressBar
    def initialize(attrs = {})
      @options = {:length => 60}.merge(attrs)
    end

    def progress(numerator, denominator)
      BarOfProgress.new(@options.merge(:total => denominator)).progress(numerator)
    end
  end
end
