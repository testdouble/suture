module Suture::Value
  class TestResults
    attr_reader :results

    def initialize(results)
      @results = results
    end

    def failed?
      @results.any? { |r| !r[:passed] }
    end

    def ran_all_tests?
      @results.all? { |r| r[:ran] }
    end

    def total_count
      @results.size
    end

    def passed_count
      @results.count { |r| r[:passed] }
    end

    def failed_count
      @results.count { |r| !r[:passed] }
    end

    def skipped_count
      @results.count { |r| !r[:ran] }
    end
  end
end

