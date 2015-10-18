module Paperclip
  module Storage
    module S3
      # Mixin which interfaces with the 'aws' and 'right_aws' libraries.
      module AwsLibrary
        protected

        def s3_connect!
          @s3 = AWS::S3.new(
            :access_key_id => @s3_credentials[:access_key_id],
            :secret_access_key => @s3_credentials[:secret_access_key],
            :server => @s3_endpoint,
            :reduced_redundancy => @s3_reduced_redundancy
          )
          @s3_bucket = @s3.buckets[bucket_name]
        end

        def s3_expiring_url(key,time)
          @s3_bucket.objects[key].url_for(:read, :expires => time)
        end

        def s3_exists?(key)
          @s3_bucket.objects[key].exists?
        end

        def s3_download(key,file)
          @s3_bucket.objects[key].read { |chunk| file.write(chunk) }
        end

        def s3_store(key,file)
          opts = {acl: @s3_permissions}
          @s3_bucket.objects[key].write(file, opts)
        end

        def s3_delete(key)
          @s3_bucket.objects[key].delete
        end
      end
    end
  end
end
