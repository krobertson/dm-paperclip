module Kernel
  def singleton_class
    (class << self; self; end)
  end unless method_defined?(:singleton_class)
end

class Class
  def define_singleton_method(*args, &block)
    singleton_class.module_eval { define_method(*args, &block) }
  end unless method_defined?(:define_singleton_method)
end
