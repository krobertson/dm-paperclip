module Paperclip
  module Resource
    def self.included(base)
      base.extend ClassMethods
      #base.class_eval do
      #  include Paperclip::Validate::ValidatesAttachmentSize
      #  include Paperclip::Validate::ValidatesAttachmentPresence
      #end
    end

   module ClassMethods
    attr_reader :attachment_definitions

    # +has_attached_file+ gives the class it is called on an attribute that maps to a file. This
    # is typically a file stored somewhere on the filesystem and has been uploaded by a user. 
    # The attribute returns a Paperclip::Attachment object which handles the management of
    # that file. The intent is to make the attachment as much like a normal attribute. The 
    # thumbnails will be created when the new file is assigned, but they will *not* be saved 
    # until +save+ is called on the record. Likewise, if the attribute is set to +nil+ is 
    # called on it, the attachment will *not* be deleted until +save+ is called. See the 
    # Paperclip::Attachment documentation for more specifics. There are a number of options 
    # you can set to change the behavior of a Paperclip attachment:
    # * +url+: The full URL of where the attachment is publically accessible. This can just
    #   as easily point to a directory served directly through Apache as it can to an action
    #   that can control permissions. You can specify the full domain and path, but usually
    #   just an absolute path is sufficient. The leading slash must be included manually for 
    #   absolute paths. The default value is "/:class/:attachment/:id/:style_:filename". See
    #   Paperclip::Attachment#interpolate for more information on variable interpolaton.
    #     :url => "/:attachment/:id/:style_:basename:extension"
    #     :url => "http://some.other.host/stuff/:class/:id_:extension"
    # * +default_url+: The URL that will be returned if there is no attachment assigned. 
    #   This field is interpolated just as the url is. The default value is 
    #   "/:class/:attachment/missing_:style.png"
    #     has_attached_file :avatar, :default_url => "/images/default_:style_avatar.png"
    #     User.new.avatar_url(:small) # => "/images/default_small_avatar.png"
    # * +styles+: A hash of thumbnail styles and their geometries. You can find more about 
    #   geometry strings at the ImageMagick website 
    #   (http://www.imagemagick.org/script/command-line-options.php#resize). Paperclip
    #   also adds the "#" option (e.g. "50x50#"), which will resize the image to fit maximally 
    #   inside the dimensions and then crop the rest off (weighted at the center). The 
    #   default value is to generate no thumbnails.
    # * +default_style+: The thumbnail style that will be used by default URLs. 
    #   Defaults to +original+.
    #     has_attached_file :avatar, :styles => { :normal => "100x100#" },
    #                       :default_style => :normal
    #     user.avatar.url # => "/avatars/23/normal_me.png"
    # * +path+: The location of the repository of attachments on disk. This can be coordinated
    #   with the value of the +url+ option to allow files to be saved into a place where Apache
    #   can serve them without hitting your app. Defaults to 
    #   ":rails_root/public/:class/:attachment/:id/:style_:filename". 
    #   By default this places the files in the app's public directory which can be served 
    #   directly. If you are using capistrano for deployment, a good idea would be to 
    #   make a symlink to the capistrano-created system directory from inside your app's 
    #   public directory.
    #   See Paperclip::Attachment#interpolate for more information on variable interpolaton.
    #     :path => "/var/app/attachments/:class/:id/:style/:filename"
    # * +whiny_thumbnails+: Will raise an error if Paperclip cannot process thumbnails of an
    #   uploaded image. This will ovrride the global setting for this attachment. 
    #   Defaults to true. 
    def has_attached_file name, options = {}
      include InstanceMethods

      @attachment_definitions ||= {} 
      @attachment_definitions[name] = options
      
      property "#{name}_file_name".to_sym, String
      property "#{name}_content_type".to_sym, String
      property "#{name}_file_size".to_sym, String

      after :save, :save_attached_files
      before :destroy, :destroy_attached_files

      define_method name do |*args|
        a = attachment_for(name)
        (args.length > 0) ? a.to_s(args.first) : a
      end

      define_method "#{name}=" do |file|
        attachment_for(name).assign(file)
      end

      define_method "#{name}?" do
        ! attachment_for(name).file.nil?
      end

        # Places ActiveRecord-style validations on the size of the file assigned. The
        # possible options are:
        # * +in+: a Range of bytes (i.e. +1..1.megabyte+),
        # * +less_than+: equivalent to :in => 0..options[:less_than]
        # * +greater_than+: equivalent to :in => options[:greater_than]..Infinity
        def validates_attachment_size(*fields)
          opts = opts_from_validator_args(fields)
          add_validator_to_context(opts, fields, Paperclip::Validate::SizeValidator)
        end

        # Places ActiveRecord-style validations on the presence of a file.
        def validates_attachment_presence(files)
          opts = opts_from_validator_args(fields)
          add_validator_to_context(opts, fields, Paperclip::Validate::RequiredFieldValidator)
        end
    end
  end

  module InstanceMethods #:nodoc:
    def attachment_for name
      @attachments ||= {}
      @attachments[name] ||= Attachment.new(name, self, self.class.attachment_definitions[name])
    end
    
    def each_attachment
      self.class.attachment_definitions.each do |name, definition|
        yield(name, attachment_for(name))
      end
    end

    def save_attached_files
      each_attachment do |name, attachment|
        attachment.send(:flush_writes)
        attachment.send(:flush_deletes)
      end
    end

    def destroy_attached_files
      each_attachment do |name, attachment|
        attachment.send(:queue_existing_for_delete)
        attachment.send(:flush_deletes)
      end
    end

  end
  end
end
