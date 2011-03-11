module Paperclip; module Ext
  module Class
    def self.inheritable_attributes(klass)
      unless klass.instance_variable_defined?(IVar)
        klass.instance_variable_set(IVar, EMPTY_INHERITABLE_ATTRIBUTES)
      end
      klass.instance_variable_get(IVar)
    end

    def self.write_inheritable_attribute(klass, key, value)
      if inheritable_attributes(klass).equal?(EMPTY_INHERITABLE_ATTRIBUTES)
        klass.instance_variable_set(IVar, {})
      end
      inheritable_attributes(klass)[key] = value
    end

    def self.read_inheritable_attribute(klass, key)
      inheritable_attributes(klass)[key]
    end

    def self.reset_inheritable_attributes(klass)
      klass.instance_variable_set(IVar, EMPTY_INHERITABLE_ATTRIBUTES)
    end

    module Hook
      def inherited(base)
        super

        attributes = ::Paperclip::Ext::Class.inheritable_attributes(self)
        new_attributes =
          if attributes.equal?(::Paperclip::Ext::Class::EMPTY_INHERITABLE_ATTRIBUTES)
            ::Paperclip::Ext::Class::EMPTY_INHERITABLE_ATTRIBUTES
          else
            attributes.inject({}) do |memo, (key, value)|
              memo[key] = ::DataMapper::Ext.try_dup(value.dup)
              memo
            end
          end

        base.instance_variable_set(::Paperclip::Ext::Class::IVar, new_attributes)
      end
    end

  private
    IVar = "@_C2DE8FA4_FDA9_45A9_8952_0AEFB571DCC1_inheritable_attributes"

    # Prevent this constant from being created multiple times
    EMPTY_INHERITABLE_ATTRIBUTES = {}.freeze
  end
end; end
