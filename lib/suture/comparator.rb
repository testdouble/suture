module Suture
  class Comparator
    DEFAULT_ACTIVE_RECORD_EXCLUDED_ATTRIBUTES = [:updated_at, :created_at]

    def initialize(options = {})
      @active_record_excluded_attributes =
        (options[:active_record_excluded_attributes] ||
         DEFAULT_ACTIVE_RECORD_EXCLUDED_ATTRIBUTES).map(&:to_s)
    end

    def call(recorded, actual)
      is_equalivalent?(recorded, actual) ||
        Marshal.dump(recorded) == Marshal.dump(actual)
    end

    protected

    def compare_active_record(recorded, actual)
      actual.kind_of?(recorded.class) &&
        without_excluded_attrs(recorded.attributes) ==
          without_excluded_attrs(actual.attributes)
    end

    private

    def without_excluded_attrs(hash)
      hash.reject do |k, v|
        @active_record_excluded_attributes.include?(k.to_s)
      end
    end

    def is_equalivalent?(recorded, actual)
      if is_active_record?(recorded, actual)
        compare_active_record(recorded, actual)
      else
        recorded == actual
      end
    end

    def is_active_record?(recorded, actual)
      defined?(ActiveRecord::Base) &&
        recorded.kind_of?(ActiveRecord::Base) &&
        actual.kind_of?(ActiveRecord::Base)
    end
  end
end
