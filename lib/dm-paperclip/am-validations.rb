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
        validates_with Paperclip::Validate::SizeValidator, _merge_attributes(fields)
      end

      # Adds errors if thumbnail creation fails. The same as specifying :whiny_thumbnails => true.
      def validates_attachment_thumbnails name, options = {}
        self.attachment_definitions[name][:whiny_thumbnails] = true
      end

      # Places ActiveRecord-style validations on the presence of a file.
      def validates_attachment_presence(*fields)
        validates_with Paperclip::Validate::RequiredFieldValidator, _merge_attributes(fields)
      end

      # Places ActiveRecord-style validations on the content type of the file assigned. The
      # possible options are:
      # * +content_type+: Allowed content types.  Can be a single content type or an array.  Allows all by default.
      # * +message+: The message to display when the uploaded file has an invalid content type.
      def validates_attachment_content_type(*fields)
        validates_with Paperclip::Validate::ContentTypeValidator, _merge_attributes(fields)
      end

    end

    class SizeValidator < ActiveModel::EachValidator #:nodoc:
     #def initialize(field_name, options={})
     #  super
     #  attribute, @options = field_name, options
     #end

      def validate_each(target, attribute, value)
        field_value = target.send(:"#{attribute}_file_size")
        return true if field_value.nil?

        @options[:in] = (@options[:greater_than]..(1/0)) unless @options[:greater_than].nil?
        @options[:in] = (0..@options[:less_than])        unless @options[:less_than].nil?
        return true if @options[:in].include? field_value.to_i

        target.errors.add(attribute, :less_than, :value => @options[:less_than]) unless @options[:less_than].nil?
        target.errors.add(attribute, :greater_than, :value => @options[:greater_than]) unless @options[:greater_than].nil?
        target.errors.add(attribute, :between, :first => @options[:in].first, :last => @options[:in].last)
        return false
      end
    end

    class RequiredFieldValidator < ActiveModel::EachValidator #:nodoc:
     #def initialize(field_name, options={})
     #  super
     #  attribute, @options = field_name, options
     #end

      def validate_each(target, attribute, value)
        field_value = target.send(attribute)
        if field_value.nil? || field_value.original_filename.blank?
          target.errors.add(attribute, :must_be_set)
          return false
        end
        return true
      end
    end

    class ContentTypeValidator < ActiveModel::EachValidator #:nodoc:
     #def initialize(field_name, options={})
     #  super
     #  attribute, @options = field_name, options
     #end

      def validate_each(target, attribute, value)
        valid_types = [@options[:content_type]].flatten
        field_value = target.send(attribute)

        unless field_value.nil? || field_value.original_filename.blank?
          unless @options[:content_type].blank?
            content_type = target.send(:"#{attribute}_content_type")
            unless valid_types.any?{|t| t === content_type }
              target.errors.add(attribute, :not_a_valid_content_type,:content_type => content_type)
              return false
            end
          end
        end

        return true
      end
    end

    class CopyAttachmentErrors < ActiveModel::EachValidator #:nodoc:
      def validate_each(target, attribute, value)
        field_value = target.send(attribute)
        unless field_value.nil? || field_value.original_filename.blank?
          return true if field_value.errors.length == 0
          field_value.errors.each { |error| target.errors.add(attribute, error.first, :message => error.last.join(", ")) } 
          return false
        end
        return true
      end
    end
  end
end

