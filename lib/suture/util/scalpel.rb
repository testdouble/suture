module Suture::Util
  class Scalpel
    def cut(plan, location, args_override = nil)
      args = args(plan, args_override)
      plan.send(location).call(*args).tap do |result|
        if after_hook = try(plan, "after_#{location}")
          after_hook.call(plan.name, location, args, result)
        end
      end
    end

    private

    def args(plan, args_override)
      return args_override if args_override
      if plan.respond_to?(:args)
        plan.args
      end
    end

    def try(plan, method)
      return unless plan.respond_to?(method)
      plan.send(method)
    end

  end
end
