module Paperclip
  module Storage
    module S3
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
    end
  end
end
