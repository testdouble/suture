module Suture::Value
  class TestPlan
    attr_accessor :name, :subject,
                  :verify_only, :fail_fast, :call_limit, :time_limit,
                  :error_message_limit, :random_seed,
                  :comparator, :database_path
    def initialize(attrs = {})
      assign_simple_ivars!(attrs, :name, :subject, :fail_fast, :comparator, :database_path)
      assign_integral_ivars(attrs, :verify_only, :call_limit, :time_limit, :error_message_limit)
      @random_seed = determine_random_seed(attrs)
    end

    private

    def assign_simple_ivars!(attrs, *names)
      names.each do |name|
        instance_variable_set("@#{name}", attrs[name])
      end
    end

    def assign_integral_ivars(attrs, *names)
      assign_simple_ivars!(
        Hash[attrs.select {|(k,_)| names.include?(k) }.
                   map { |(k,v)| [k, v.nil? ? nil : v.to_i]}],
        *names
      )
    end

    def determine_random_seed(attrs)
      if attrs.has_key?(:random_seed)
        if attrs[:random_seed].nil? || attrs[:random_seed] == "nil"
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
