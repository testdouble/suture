module Suture::Value
  class TestPlan
    attr_accessor :name, :subject, :args, :fail_fast, :database_path
    def initialize(attrs = {})
      @name = attrs[:name]
      @subject = attrs[:subject]
      @args = attrs[:args]
      @fail_fast = attrs[:fail_fast]
      @database_path = attrs[:database_path]
    end
  end
end
