module Suture::Util
  module Env
    def self.to_map(excludes = {})
      Hash[
        ENV.keys.
          select { |k| k.start_with?("SUTURE_") }.
          map { |k| [to_sym(k), sanitize_value(ENV[k])] }
      ].reject { |(k, _)| excludes.include?(k) }
    end

    # private

    def self.to_sym(name)
      name.gsub(/^SUTURE\_/, "").downcase.to_sym
    end

    def self.sanitize_value(value)
      if value == "false"
        false
      elsif value == "true"
        true
      else
        value
      end
    end
  end
end
