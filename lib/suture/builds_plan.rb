module Suture
  class BuildsPlan
    UN_ENV_IABLE_OPTIONS = [:name, :old, :new, :args]

    def build(name, options = {})
      Value::Plan.new(options.merge(:name => name).merge(env))
    end

  private

    def env
      Hash[ENV.keys.
          select { |k| k.start_with?("SUTURE_") }.
          map { |k| [env_var_name_to_option_name(k), ENV[k]] }].
          reject { |(k,v)| UN_ENV_IABLE_OPTIONS.include?(k) }
    end

    def env_var_name_to_option_name(name)
      name.gsub(/^SUTURE\_/,'').downcase.to_sym
    end
  end
end
