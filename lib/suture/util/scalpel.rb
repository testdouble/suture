require "suture/adapter/log"

module Suture::Util
  class Scalpel
    include Suture::Adapter::Log

    def cut(plan, location, args_override = nil)
      args = args(plan, args_override)
      begin
        plan.send(location).call(*args).tap do |result|
          call_after_hook(plan, location, args, result)
        end
      rescue StandardError => error
        log_error_details(plan, location, args, error)
        call_error_hook(plan, location, args, error)
        raise error
      end
    end

    private

    def call_after_hook(plan, location, args, result)
      return unless after_hook = try(plan, "after_#{location}")
      after_hook.call(plan.name, args, result)
    end

    def log_error_details(plan, location, args, error)
      return if expected_error?(plan, error)
      log_error <<-MSG.gsub(/^ {8}/,'')
        Suture invoked the #{plan.name.inspect} seam's #{location.inspect} code path with args: ```
          #{args.inspect}
        ```
        which raised a #{error.class} with message: ```
          #{error.message}
        ```
      MSG
    end

    def call_error_hook(plan, location, args, error)
      return if expected_error?(plan, error)
      return unless error_hook = try(plan, "on_#{location}_error")
      error_hook.call(plan.name, args, error)
    end

    def expected_error?(plan, error)
      plan.expected_error_types.any? {|e| error.kind_of?(e) }
    end

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
