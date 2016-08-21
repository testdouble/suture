module Suture::Util
  module Env
    def self.to_map(excludes = {})
      Hash[
        ENV.keys.
            select { |k| k.start_with?("SUTURE_") }.
            map { |k| [to_sym(k), sanitize_value(ENV[k])] }
      ].reject { |(k,v)| excludes.include?(k) }
    end

    # private

    def self.to_sym(name)
      name.gsub(/^SUTURE\_/,'').downcase.to_sym
    end

    def self.sanitize_value(value)
      return false if value == "false"
      value
    end
  end
end
