module Suture::Value
  class TestPlan
    attr_accessor :name, :subject, :verify_only,
                  :fail_fast, :comparator, :database_path
    def initialize(attrs = {})
      @name = attrs[:name]
      @subject = attrs[:subject]
      @verify_only = attrs[:verify_only].to_i if attrs[:verify_only]
      @fail_fast = attrs[:fail_fast]
      @comparator = attrs[:comparator]
      @database_path = attrs[:database_path]
    end
  end
end
