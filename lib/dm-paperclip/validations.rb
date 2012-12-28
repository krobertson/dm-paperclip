module Paperclip
  module Validate

    module ClassMethods

      # Places ActiveRecord-style validations on the size of the file assigned. The
      # possible options are:
      # * +in+: a Range of bytes (i.e. +1..1.megabyte+),
      # * +less_than+: equivalent to :in => 0..options[:less_than]
      # * +greater_than+: equivalent to :in => options[:greater_than]..Infinity
      # * +message+: error message to display, use :min and :max as replacements
      def validates_attachment_size(*fields)
        validators.add(Paperclip::Validate::SizeValidator, *fields)
      end

      # Adds errors if thumbnail creation fails. The same as specifying :whiny_thumbnails => true.
      def validates_attachment_thumbnails name, options = {}
        self.attachment_definitions[name][:whiny_thumbnails] = true
      end

      # Places ActiveRecord-style validations on the presence of a file.
      def validates_attachment_presence(*fields)
        validators.add(Paperclip::Validate::RequiredFieldValidator, *fields)
      end

      # Places ActiveRecord-style validations on the content type of the file assigned. The
      # possible options are:
      # * +content_type+: Allowed content types.  Can be a single content type or an array.  Allows all by default.
      # * +message+: The message to display when the uploaded file has an invalid content type.
      def validates_attachment_content_type(*fields)
        validators.add(Paperclip::Validate::ContentTypeValidator, *fields)
      end

    end

    class SizeValidator < DataMapper::Validate::GenericValidator #:nodoc:
      def call(target)
        field_value = target.validation_property_value(:"#{@field_name}_file_size")
        return true if field_value.nil?

        @options[:in] = (@options[:greater_than]..(1.0/0)) unless @options[:greater_than].nil?
        @options[:in] = (0..@options[:less_than])        unless @options[:less_than].nil?
        return true if @options[:in].include? field_value.to_i

        error_message ||= @options[:message] unless @options[:message].nil?
        error_message ||= sprintf("%s must be less than %s bytes",DataMapper::Inflector.humanize(@field_name), @options[:less_than]) unless @options[:less_than].nil?
        error_message ||= sprintf("%s must be greater than %s bytes",DataMapper::Inflector.humanize(@field_name), @options[:greater_than]) unless @options[:greater_than].nil?
        error_message ||= sprintf("%s must be between %s and %s bytes",DataMapper::Inflector.humanize(@field_name), @options[:in].first, @options[:in].last)
        add_error(target, error_message , @field_name)
        return false
      end
    end

    class RequiredFieldValidator < DataMapper::Validate::GenericValidator #:nodoc:
      def call(target)
        field_value = target.validation_property_value(@field_name)
        if field_value.nil? || Paperclip::Ext.blank?(field_value.original_filename)
          error_message = @options[:message] || sprintf("%s must be set",DataMapper::Inflector.humanize(@field_name))
          add_error(target, error_message , @field_name)
          return false
        end
        return true
      end
    end

    class ContentTypeValidator < DataMapper::Validate::GenericValidator #:nodoc:
      def call(target)
        valid_types = [@options[:content_type]].flatten
        field_value = target.validation_property_value(@field_name)

        unless field_value.nil? || Paperclip::Ext.blank?(field_value.original_filename)
          unless Paperclip::Ext.blank?(@options[:content_type])
            content_type = target.validation_property_value(:"#{@field_name}_content_type")
            unless valid_types.any?{|t| t === content_type }
              error_message ||= @options[:message] unless @options[:message].nil?
              error_message ||= sprintf("%s's content type of '%s' is not a valid content type",DataMapper::Inflector.humanize(@field_name), content_type)
              add_error(target, error_message , @field_name)
              return false
            end
          end
        end

        return true
      end
    end

    class CopyAttachmentErrors < DataMapper::Validate::GenericValidator #:nodoc:
      def call(target)
        field_value = target.validation_property_value(@field_name)
        unless field_value.nil? || Paperclip::Ext.blank?(field_value.original_filename)
          return true if field_value.errors.length == 0
          field_value.errors.each do |error, message|
            [message].flatten.each { |m| add_error(target, m, @field_name) }
          end
          return false
        end
        return true
      end
    end

  end
end

