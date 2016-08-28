require "suture/value/plan"
require "suture/util/env"

module Suture
  class BuildsPlan
    UN_ENV_IABLE_OPTIONS = [:name, :old, :new, :args,
                            :comparator, :after_new, :after_old]

    def build(name, options = {})
      Value::Plan.new(
        Suture.config.
          merge(options).
          merge(:name => name).
          merge(Suture::Util::Env.to_map(UN_ENV_IABLE_OPTIONS))
      )
    end
  end
end
