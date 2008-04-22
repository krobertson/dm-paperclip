require 'tempfile'
require 'validatable'
require File.join(File.dirname(__FILE__), 'dm-paperclip', 'upfile')
require File.join(File.dirname(__FILE__), 'dm-paperclip', 'iostream')
require File.join(File.dirname(__FILE__), 'dm-paperclip', 'geometry')
require File.join(File.dirname(__FILE__), 'dm-paperclip', 'thumbnail')
require File.join(File.dirname(__FILE__), 'dm-paperclip', 'validations')
require File.join(File.dirname(__FILE__), 'dm-paperclip', 'resource')
require File.join(File.dirname(__FILE__), 'dm-paperclip', 'attachment')

module Paperclip
  class << self
    # Provides configurability to Paperclip. There are a number of options available, such as:
    # * whiny_thumbnails: Will raise an error if Paperclip cannot process thumbnails of 
    #   an uploaded image. Defaults to true.
    # * image_magick_path: Defines the path at which to find the +convert+ and +identify+ 
    #   programs if they are not visible to Rails the system's search path. Defaults to 
    #   nil, which uses the first executable found in the search path.
    def options
      @options ||= {
        :whiny_thumbnails  => true,
        :image_magick_path => nil
      }
    end

    def path_for_command command #:nodoc:
      path = [options[:image_magick_path], command].compact
      File.join(*path)
    end

    def included base #:nodoc:
      base.extend Paperclip::AttachmentResource
    end
  end

  class PaperclipError < StandardError #:nodoc:
  end
end
