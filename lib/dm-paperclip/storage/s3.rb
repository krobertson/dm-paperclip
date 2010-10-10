module Paperclip
  module Storage
    # Amazon's S3 file hosting service is a scalable, easy place to store
    # files for distribution. You can find out more about it at
    # http://aws.amazon.com/s3. There are a few S3-specific options for
    # +has_attached_file+:
    # * +s3_credentials+: Takes a path, a File, or a Hash. The path
    #   (or File) must point to a YAML file containing the
    #   +access_key_id+ and +secret_access_key+ that Amazon gives you.
    #   You can 'environment-space' this just like you do to your
    #   +database.yml+ file, so different environments can use different
    #   accounts:
    #
    #     development:
    #       access_key_id: 123...
    #       secret_access_key: 123... 
    #     test:
    #       access_key_id: abc...
    #       secret_access_key: abc... 
    #     production:
    #       access_key_id: 456...
    #       secret_access_key: 456... 
    #
    #   This is not required, however, and the file may simply look like
    #   this:
    #
    #     access_key_id: 456...
    #     secret_access_key: 456... 
    #
    #   In which case, those access keys will be used in all environments.
    #   You can also put your bucket name in this file, instead of adding
    #   it to the code directly. This is useful when you want the same
    #   account but a different bucket for  development versus production.
    # * +s3_permissions+: This is a String that should be one of the
    #   "canned" access policies that S3 provides (more information can be
    #   found here: http://docs.amazonwebservices.com/AmazonS3/2006-03-01/RESTAccessPolicy.html#RESTCannedAccessPolicies).
    #   The default for Paperclip is +:public_read+.
    # * +s3_protocol+: The protocol for the URLs generated to your S3
    #   assets. Can be either 'http' or 'https'. Defaults to 'http' when
    #   your +:s3_permissions+ are +:public_read+ (the default), and 'https'
    #   when your +:s3_permissions+ are anything else.
    # * +s3_headers+: A hash of headers such as:
    #
    #     {'Expires' => 1.year.from_now.httpdate}
    #
    # * +bucket+: This is the name of the S3 bucket that will store your
    #   files. Remember that the bucket must be unique across all of
    #   Amazon S3. If the bucket does not exist Paperclip will attempt to
    #   create it. The bucket name will not be interpolated. You can define
    #   the bucket as a Proc if you want to determine it's name at runtime.
    #   Paperclip will call that Proc with attachment as the only argument.
    # * +s3_host_alias+: The fully-qualified domain name (FQDN) that is the
    #   alias to the S3 domain of your bucket. Used with the +:s3_alias_url+
    #   url interpolation. See the link in the +url+ entry for more
    #   information about S3 domains and buckets.
    # * +url+: There are three options for the S3 url. You can choose to
    #   have the bucket's name placed domain-style
    #   (bucket.s3.amazonaws.com) or path-style (s3.amazonaws.com/bucket).
    #   Lastly, you can specify a CNAME (which requires the CNAME to be
    #   specified as +:s3_alias_url+. You can read more about CNAMEs and S3
    #   at http://docs.amazonwebservices.com/AmazonS3/latest/index.html?VirtualHosting.html.
    #   Normally, this won't matter in the slightest and you can leave the
    #   default (which is path-style, or +:s3_path_url+). But in some cases
    #   paths don't work and you need to use the domain-style
    #   (+:s3_domain_url+). Anything else here will be treated like
    #   path-style.
    #   NOTE: If you use a CNAME for use with CloudFront, you can NOT
    #   specify https as your +:s3_protocol+; This is *not supported* by
    #   S3/CloudFront. Finally, when using the host alias, the +:bucket+
    #   parameter is ignored, as the hostname is used as the bucket name
    #   by S3.
    # * +path+: This is the key under the bucket in which the file will be
    #   stored. The URL will be constructed from the bucket and the path.
    #   This is what you will want to interpolate. Keys should be unique,
    #   like filenames, and despite the fact that S3 (strictly speaking)
    #   does not support directories, you can still use a / to separate
    #   parts of your file name.
    module S3
      # Mixin which interfaces with the 'aws' library.
      module AwsLibrary
        protected

        def s3_connect!
          @s3 = Aws::S3.new(
            @s3_credentials[:access_key_id],
            @s3_credentials[:secret_access_key]
          )
          @s3_bucket = @s3.bucket(bucket_name)
        end

        def s3_expiring_url(key,time)
          @s3.get_link(bucket_name,key,time)
        end

        def s3_exists?(key)
          @s3_bucket.keys(:prefix => key).include?(key)
        end

        def s3_download(key,file)
          @s3_bucket.key(key).get { |chunk| file.write(chunk) }
        end

        def s3_store(key,file)
          @s3_bucket.key(key).put(
            file,
            @s3_permissions.to_s.gsub('_','-')
          )
        end

        def s3_delete(key)
          @s3_bucket.key(key).delete
        end
      end

      # Mixin which interfaces with the 'aws-s3' library.
      module AwsS3Library
        protected

        def s3_connect!
          AWS::S3::Base.establish_connection!(@s3_options.merge(
            :access_key_id => @s3_credentials[:access_key_id],
            :secret_access_key => @s3_credentials[:secret_access_key]
          ))
        end

        def s3_expiring_url(key,time)
          AWS::S3::S3Object.url_for(key, bucket_name, :expires_in => time)
        end

        def s3_exists?(key)
          AWS::S3::S3Object.exists?(key, bucket_name)
        end

        def s3_download(key,file)
          file.write(AWS::S3::S3Object.value(key, bucket_name))
        end

        def s3_store(key,file)
          begin
            AWS::S3::S3Object.store(
              key,
              file,
              bucket_name,
              {
                :content_type => instance_read(:content_type),
                :access => @s3_permissions,
              }.merge(@s3_headers)
            )
          rescue AWS::S3::ResponseError => e
            raise
          end
        end

        def s3_delete(key)
          begin
            AWS::S3::S3Object.delete(key, bucket_name)
          rescue AWS::S3::ResponseError
            # Ignore this.
          end
        end
      end

      # Libraries and mixins that provide S3 support
      LIBRARIES = {
        'aws/s3' => AwsS3Library,
        'aws' => AwsLibrary
      }

      def self.extended(base)
        # attempt to load one of the S3 libraries
        s3_detected = LIBRARIES.any? do |path,mixin|
          begin
            require path

            base.send :extend, mixin
            true
          rescue LoadError => e
            false
          end
        end

        unless s3_detected
          raise(LoadError,"unable to load any S3 library (#{LIBRARIES.keys.join(', ')})",caller)
        end

        base.instance_eval do
          @s3_credentials = parse_credentials(@options[:s3_credentials])
          @bucket         = (@options[:bucket] || @s3_credentials[:bucket])
          @bucket         = @bucket.call(self) if @bucket.is_a?(Proc)
          @s3_options     = (@options[:s3_options] || {})
          @s3_permissions = (@options[:s3_permissions] || :public_read)
          @s3_protocol    = (@options[:s3_protocol] || (@s3_permissions == :public_read ? 'http' : 'https'))
          @s3_headers     = (@options[:s3_headers] || {})
          @s3_host_alias  = @options[:s3_host_alias]
          @url            = ':s3_path_url' unless @url.to_s.match(/^:s3.*url$/)

          s3_connect!
        end

        Paperclip.interpolates(:s3_alias_url) do |attachment, style|
          "#{attachment.s3_protocol}://#{attachment.s3_host_alias}/#{attachment.path(style).gsub(%r{^/}, '')}"
        end

        Paperclip.interpolates(:s3_path_url) do |attachment, style|
          "#{attachment.s3_protocol}://s3.amazonaws.com/#{attachment.bucket_name}/#{attachment.path(style).gsub(%r{^/}, '')}"
        end

        Paperclip.interpolates(:s3_domain_url) do |attachment, style|
          "#{attachment.s3_protocol}://#{attachment.bucket_name}.s3.amazonaws.com/#{attachment.path(style).gsub(%r{^/}, '')}"
        end
      end
      
      def expiring_url(time = 3600)
        s3_expiring_url(path, time)
      end

      def bucket_name
        @bucket
      end

      def s3_host_alias
        @s3_host_alias
      end

      def parse_credentials(creds)
        creds = find_credentials(creds).to_mash.stringify_keys!
        if defined?(Merb) && Merb.respond_to?(:env)
          (creds[Merb.env] || creds).symbolize_keys
        elsif defined?(RAILS_ENV)
          (creds[RAILS_ENV] || creds).symbolize_keys
        elsif defined?(Rails) && Rails.respond_to(:env)
          (creds[Rails.env] || creds).symbolize_keys
        elsif defined?(RACK_ENV)
          (creds[RACK_ENV] || creds).symbolize_keys
        else
          creds.symbolize_keys
        end
      end
      
      def exists?(style = default_style)
        if original_filename
          s3_exists?(path(style))
        else
          false
        end
      end

      def s3_protocol
        @s3_protocol
      end

      # Returns representation of the data of the file assigned to the given
      # style, in the format most representative of the current storage.
      def to_file(style = default_style)
        if @queued_for_write[style]
          @queued_for_write[style]
        else
          key = path(style)
          file = Tempfile.new(key)

          s3_download(key,file)

          file.rewind
          file
        end
      end

      def flush_writes #:nodoc:
        @queued_for_write.each do |style, file|
          log("saving #{path(style)}")
          s3_store(path(style),file)
        end

        @queued_for_write = {}
      end

      def flush_deletes #:nodoc:
        @queued_for_delete.each do |path|
          log("deleting #{path}")
          s3_delete(path)
        end

        @queued_for_delete = []
      end

      private
      
      def find_credentials(creds)
        case creds
        when File
          YAML::load(ERB.new(File.read(creds.path)).result)
        when Pathname, String
          YAML::load(ERB.new(File.read(creds)).result)
        when Hash
          creds
        else
          raise ArgumentError, 'Credentials are not a path, file, or hash.'
        end
      end

    end
  end
end
