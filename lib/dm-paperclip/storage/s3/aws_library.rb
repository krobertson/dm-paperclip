module Paperclip
  module Storage
    module S3
      # Mixin which interfaces with the 'aws' and 'right_aws' libraries.
      module AwsLibrary
        protected

        def s3_connect!
          @s3 = Aws::S3.new(
            @s3_credentials[:access_key_id],
            @s3_credentials[:secret_access_key]
            @s3_credentials[:server]
          )
          @s3_bucket = @s3.bucket(bucket_name)
        end

        def s3_expiring_url(key,time)
          @s3.interface.get_link(bucket_name,key,time)
        end

        def s3_exists?(key)
          @s3_bucket.keys(:prefix => key).any? { |s3_key| s3_key.name == key }
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
    end
  end
end
