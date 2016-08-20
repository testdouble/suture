module Suture::Value
  class TestResults
    def initialize(results)
      @results = results
    end

    def failed?
      @results.any? { |r| !r[:passed] }
    end
  end
end

