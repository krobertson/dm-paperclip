# Paperclip allows file attachments that are stored in the filesystem. All graphical
# transformations are done using the Graphics/ImageMagick command line utilities and
# are stored in Tempfiles until the record is saved. Paperclip does not require a
# separate model for storing the attachment's information, instead adding a few simple
# columns to your table.
#
# Author:: Jon Yurek
# Copyright:: Copyright (c) 2008 thoughtbot, inc.
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)
#
# Paperclip defines an attachment as any file, though it makes special considerations
# for image files. You can declare that a model has an attached file with the
# +has_attached_file+ method:
#
#   class User < ActiveRecord::Base
#     has_attached_file :avatar, :styles => { :thumb => "100x100" }
#   end
#
#   user = User.new
#   user.avatar = params[:user][:avatar]
#   user.avatar.url
#   # => "/users/avatars/4/original_me.jpg"
#   user.avatar.url(:thumb)
#   # => "/users/avatars/4/thumb_me.jpg"
#
# See the +has_attached_file+ documentation for more details.

require 'erb'
require 'digest'
require 'tempfile'

require 'dm-core'
require 'extlib'

require 'dm-paperclip/ext/compatibility'
require 'dm-paperclip/ext/class'
require 'dm-paperclip/ext/blank'
require 'dm-paperclip/ext/try_dup'
require 'dm-paperclip/version'
require 'dm-paperclip/upfile'
require 'dm-paperclip/iostream'
require 'dm-paperclip/geometry'
require 'dm-paperclip/processor'
require 'dm-paperclip/thumbnail'
require 'dm-paperclip/interpolations'
require 'dm-paperclip/style'
require 'dm-paperclip/attachment'
require 'dm-paperclip/storage'
require 'dm-paperclip/command_line'
require 'dm-paperclip/callbacks'

# The base module that gets included in ActiveRecord::Base. See the
# documentation for Paperclip::ClassMethods for more useful information.
module Paperclip

  # To configure Paperclip, put this code in an initializer, Rake task, or wherever:
  #
  #   Paperclip.configure do |config|
  #     config.root               = Rails.root # the application root to anchor relative urls (defaults to Dir.pwd)
  #     config.env                = Rails.env  # server env support, defaults to ENV['RACK_ENV'] or 'development'
  #     config.use_dm_validations = true       # validate attachment sizes and such, defaults to false
  #     config.processors_path    = 'lib/pc'   # relative path to look for processors, defaults to 'lib/paperclip_processors'
  #   end
  #
  def self.configure
    yield @config = Configuration.new
    Paperclip.config = @config
  end

  def self.config=(config)
    @config = config
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.require_processors
    return if @processors_already_required
    Dir.glob(File.expand_path("#{Paperclip.config.processors_path}/*.rb")).sort.each do |processor|
      require processor
    end
    @processors_already_required = true
  end

  class Configuration

    DEFAULT_PROCESSORS_PATH = 'lib/paperclip_processors'

    attr_writer   :root, :env
    attr_accessor :use_dm_validations

    def root
      @root ||= Dir.pwd
    end

    def env
      @env ||= (ENV['RACK_ENV'] || 'development')
    end

    def processors_path=(path)
      @processors_path = File.expand_path(path, root)
    end

    def processors_path
      @processors_path ||= File.expand_path("../#{DEFAULT_PROCESSORS_PATH}", root)
    end

  end

  class << self

    # Provides configurability to Paperclip. There are a number of options available, such as:
    # * whiny: Will raise an error if Paperclip cannot process thumbnails of
    #   an uploaded image. Defaults to true.
    # * log: Logs progress to the Rails log. Uses ActiveRecord's logger, so honors
    #   log levels, etc. Defaults to true.
    # * command_path: Defines the path at which to find the command line
    #   programs if they are not visible to Rails the system's search path. Defaults to
    #   nil, which uses the first executable found in the user's search path.
    # * image_magick_path: Deprecated alias of command_path.
    def options
      @options ||= {
        :whiny             => true,
        :image_magick_path => nil,
        :command_path      => nil,
        :log               => true,
        :log_command       => true,
        :swallow_stderr    => true
      }
    end

    def path_for_command command #:nodoc:
      if options[:image_magick_path]
        warn("[DEPRECATION] :image_magick_path is deprecated and will be removed. Use :command_path instead")
      end
      path = [options[:command_path] || options[:image_magick_path], command].compact
      File.join(*path)
    end

    def interpolates key, &block
      Paperclip::Interpolations[key] = block
    end

    # The run method takes a command to execute and an array of parameters
    # that get passed to it. The command is prefixed with the :command_path
    # option from Paperclip.options. If you have many commands to run and
    # they are in different paths, the suggested course of action is to
    # symlink them so they are all in the same directory.
    #
    # If the command returns with a result code that is not one of the
    # expected_outcodes, a PaperclipCommandLineError will be raised. Generally
    # a code of 0 is expected, but a list of codes may be passed if necessary.
    # These codes should be passed as a hash as the last argument, like so:
    #
    #   Paperclip.run("echo", "something", :expected_outcodes => [0,1,2,3])
    #
    # This method can log the command being run when
    # Paperclip.options[:log_command] is set to true (defaults to false). This
    # will only log if logging in general is set to true as well.
    def run cmd, *params
      if options[:image_magick_path]
        Paperclip.log("[DEPRECATION] :image_magick_path is deprecated and will be removed. Use :command_path instead")
      end
      CommandLine.path = options[:command_path] || options[:image_magick_path]
      CommandLine.new(cmd, *params).run
    end

    def included base #:nodoc:
      base.extend ClassMethods
      unless base.respond_to?(:define_callbacks)
        base.send(:include, Paperclip::CallbackCompatability)
      end
    end

    def processor name #:nodoc:
      name = DataMapper::Inflector.classify(name.to_s)
      processor = Paperclip.const_get(name)
      unless processor.ancestors.include?(Paperclip::Processor)
        raise PaperclipError.new("[paperclip] Processor #{name} was not found")
      end
      processor
    end

    def each_instance_with_attachment(klass, name)
      Object.const_get(klass).all.each do |instance|
        yield(instance) if instance.send(:"#{name}?")
      end
    end

    # Log a paperclip-specific line. Uses ActiveRecord::Base.logger
    # by default. Set Paperclip.options[:log] to false to turn off.
    def log message
      logger.info("[paperclip] #{message}") if logging?
    end

    def logger #:nodoc:
      DataMapper.logger
    end

    def logging? #:nodoc:
      options[:log]
    end
  end

  class PaperclipError < StandardError #:nodoc:
  end

  class PaperclipCommandLineError < PaperclipError #:nodoc:
    attr_accessor :output
    def initialize(msg = nil, output = nil)
      super(msg)
      @output = output
    end
  end

  class StorageMethodNotFound < PaperclipError
  end

  class CommandNotFoundError < PaperclipError
  end

  class NotIdentifiedByImageMagickError < PaperclipError #:nodoc:
  end

  class InfiniteInterpolationError < PaperclipError #:nodoc:
  end

  module Resource
    def self.included(base)
      base.extend Paperclip::ClassMethods
      base.extend Paperclip::Ext::Class::Hook

      # Done at this time to ensure that the user
      # had a chance to configure the app in an initializer
      if Paperclip.config.use_dm_validations
        require 'dm-validations'
        require 'dm-paperclip/validations'
        base.extend Paperclip::Validate::ClassMethods
      end

      Paperclip.require_processors
    end
  end

  module ClassMethods
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
    #   just an absolute path is sufficient. The leading slash *must* be included manually for
    #   absolute paths. The default value is
    #   "/system/:attachment/:id/:style/:filename". See
    #   Paperclip::Attachment#interpolate for more information on variable interpolaton.
    #     :url => "/:class/:attachment/:id/:style_:filename"
    #     :url => "http://some.other.host/stuff/:class/:id_:extension"
    # * +default_url+: The URL that will be returned if there is no attachment assigned.
    #   This field is interpolated just as the url is. The default value is
    #   "/:attachment/:style/missing.png"
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
    # * +whiny+: Will raise an error if Paperclip cannot post_process an uploaded file due
    #   to a command line error. This will override the global setting for this attachment.
    #   Defaults to true. This option used to be called :whiny_thumbanils, but this is
    #   deprecated.
    # * +convert_options+: When creating thumbnails, use this free-form options
    #   array to pass in various convert command options.  Typical options are "-strip" to
    #   remove all Exif data from the image (save space for thumbnails and avatars) or
    #   "-depth 8" to specify the bit depth of the resulting conversion.  See ImageMagick
    #   convert documentation for more options: (http://www.imagemagick.org/script/convert.php)
    #   Note that this option takes a hash of options, each of which correspond to the style
    #   of thumbnail being generated. You can also specify :all as a key, which will apply
    #   to all of the thumbnails being generated. If you specify options for the :original,
    #   it would be best if you did not specify destructive options, as the intent of keeping
    #   the original around is to regenerate all the thumbnails when requirements change.
    #     has_attached_file :avatar, :styles => { :large => "300x300", :negative => "100x100" }
    #                                :convert_options => {
    #                                  :all => "-strip",
    #                                  :negative => "-negate"
    #                                }
    #   NOTE: While not deprecated yet, it is not recommended to specify options this way.
    #   It is recommended that :convert_options option be included in the hash passed to each
    #   :styles for compatability with future versions.
    #   NOTE: Strings supplied to :convert_options are split on space in order to undergo
    #   shell quoting for safety. If your options require a space, please pre-split them
    #   and pass an array to :convert_options instead.
    # * +storage+: Chooses the storage backend where the files will be stored. The current
    #   choices are :filesystem and :s3. The default is :filesystem. Make sure you read the
    #   documentation for Paperclip::Storage::Filesystem and Paperclip::Storage::S3
    #   for backend-specific options.
    def has_attached_file name, options = {}
      include InstanceMethods

      Paperclip::Ext::Class.write_inheritable_attribute(self, :attachment_definitions, {}) if attachment_definitions.nil?
      attachment_definitions[name] = {:validations => []}.merge(options)

      property_options = options.delete_if { |k,v| ![ :public, :protected, :private, :accessor, :reader, :writer ].include?(key) }
      property_options[:required] = false

      property :"#{name}_file_name",    String,   property_options.merge(:length => 255)
      property :"#{name}_content_type", String,   property_options.merge(:length => 255)
      property :"#{name}_file_size",    Integer,  property_options
      property :"#{name}_updated_at",   DateTime, property_options

      after :save, :save_attached_files
      before :destroy, :destroy_attached_files

      Paperclip::Callbacks.define(self, "post_process")
      Paperclip::Callbacks.define(self, "#{name}_post_process")

      define_method name do |*args|
        a = attachment_for(name)
        (args.length > 0) ? a.to_s(args.first) : a
      end

      define_method "#{name}=" do |file|
        attachment_for(name).assign(file)
      end

      define_method "#{name}?" do
        attachment_for(name).file?
      end

      if Paperclip.config.use_dm_validations
        validators.add(Paperclip::Validate::CopyAttachmentErrors, name)
      end

    end

    # Returns the attachment definitions defined by each call to
    # has_attached_file.
    def attachment_definitions
      Paperclip::Ext::Class.read_inheritable_attribute(self, :attachment_definitions)
    end
  end

  module InstanceMethods #:nodoc:
    def attachment_for name
      @_paperclip_attachments ||= {}
      @_paperclip_attachments[name] ||= Attachment.new(name, self, self.class.attachment_definitions[name])
    end

    def each_attachment
      self.class.attachment_definitions.each do |name, definition|
        yield(name, attachment_for(name))
      end
    end

    def save_attached_files
      Paperclip.log("Saving attachments.")
      each_attachment do |name, attachment|
        attachment.send(:save)
      end
    end

    def destroy_attached_files
      Paperclip.log("Deleting attachments.")
      each_attachment do |name, attachment|
        attachment.send(:queue_existing_for_delete)
        attachment.send(:flush_deletes)
      end
    end
  end
end
