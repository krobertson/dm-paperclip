module Paperclip
  module Validate

    module ValidatesAttachmentSize
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
      end
    end

    class SizeValidator < DataMapper::Validate::GenericValidator #:nodoc:
      def initialize(field_name, options={})
        super
        @field_name, @options = field_name, options
      end

      def call(target)
        field_value = target.validation_property_value(:"#{@field_name}_file_size")
        return true if field_value.nil?

        @options[:in] = (@options[:greater_than]..(1/0)) unless @options[:greater_than].nil?
        @options[:in] = (0..@options[:less_than])        unless @options[:less_than].nil?
        return true if @options[:in].include? field_value.to_i

        error_message ||= @options[:message] unless @options[:message].nil?
        error_message ||= "%s must be less than %s bytes".t(DataMapper::Inflection.humanize(@field_name), @options[:less_than]) unless @options[:less_than].nil?
        error_message ||= "%s must be greater than %s bytes".t(DataMapper::Inflection.humanize(@field_name), @options[:greater_than]) unless @options[:greater_than].nil?
        error_message ||= "%s must be between %s and %s bytes".t(DataMapper::Inflection.humanize(@field_name), @options[:in].first, @options[:in].last)
        add_error(target, error_message , @field_name)
        return false
      end
    end

    module ValidatesAttachmentPresence
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
      end
    end

    class RequiredFieldValidator < DataMapper::Validate::GenericValidator #:nodoc:
      def initialize(field_name, options={})
        super
        @field_name, @options = field_name, options
      end

      def call(target)
        value = target.validation_property_value(@field_name)
        return true if !value.blank?

        error_message = @options[:message] || "%s must not be blank".t(DataMapper::Inflection.humanize(@field_name))
        add_error(target, error_message , @field_name)

        return false
      end

      def call(target)
        field_value = target.validation_property_value(@field_name)
        if field_value.nil? || field_value.file.nil? || !File.exist(field_value.file.path)
          error_message = @options[:message] || "%s must be set".t(DataMapper::Inflection.humanize(@field_name))
          add_error(target, error_message , @field_name)
          return false
        end
        return true
      end
    end

  end
end

