module Paperclip; module Callbacks
  class << self
    def define(klass, name)
      ["before_#{name}", "after_#{name}"].each do |method|
        klass.define_singleton_method(method) do |callback|
          callbacks = (@_C2DE8FA4_FDA9_45A9_8952_0AEFB571DCC1_callbacks ||= {})
          callbacks[method] ||= []
          callbacks[method] << callback
          nil
        end
      end
    end

    def run(instance, name, &block)
      return false if run_callbacks(instance, "before_#{name}") == false
      result = yield
      return false if result == false
      return false if run_callbacks(instance, "after_#{name}", true) == false
      block_given? ? result : true
    end

  private
    def collect_callbacks(instance)
      instance.class.ancestors.inject({}) do |memo, ancestor|
        callbacks = ancestor.instance_variable_get(:@_C2DE8FA4_FDA9_45A9_8952_0AEFB571DCC1_callbacks)
        if callbacks
          callbacks.each do |name, methods|
            memo[name] = methods + (memo[name] || [])
          end
        end
        memo
      end
    end

    def run_callbacks(instance, name, reversed = false)
      #return true unless callbacks = instance.class._C2DE8FA4_FDA9_45A9_8952_0AEFB571DCC1_callbacks
      return true unless callbacks = collect_callbacks(instance)
      return true unless callbacks = callbacks[name]

      callbacks = callbacks.reverse if reversed
      callbacks.each do |callback|
        result =
          case callback
          when Symbol
            instance.send(callback)
          when Proc
            callback.call(instance)
          end
        return false if result == false
      end

      true
    end
  end
end; end
