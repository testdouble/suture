module Suture::Value
  class TestPlan
    attr_accessor :name, :subject,
                  :verify_only, :fail_fast, :random_seed,
                  :comparator, :database_path
    def initialize(attrs = {})
      @name = attrs[:name]
      @subject = attrs[:subject]
      @verify_only = attrs[:verify_only].to_i if attrs[:verify_only]
      @fail_fast = attrs[:fail_fast]
      @random_seed = determine_random_seed(attrs)
      @comparator = attrs[:comparator]
      @database_path = attrs[:database_path]
    end

    private

    def determine_random_seed(attrs)
      if attrs.has_key?(:random_seed)
        if attrs[:random_seed].nil?
          nil
        else
          attrs[:random_seed].to_i
        end
      else
        rand(99999)
      end
    end
  end
end
