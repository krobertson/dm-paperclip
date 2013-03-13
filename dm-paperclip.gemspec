#encoding: utf-8

# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = 'dm-paperclip-s3'
  s.version = '1.0.0'
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["README.rdoc", "LICENSE" ]
  s.summary = "File attachments as attributes for DataMapper, based on the Paperclip by Ken Robertson, updated for Amazon S3 storage"
  s.description = s.summary
  s.author = "Marcin Krzyżanowski"
  s.email = "marcin.krzyzanowski@hakore.com"
  s.homepage = "http://github.com/krzak/dm-paperclip"

  s.require_path = 'lib'
  s.files = Dir.glob("lib/**/*")
  s.requirements = ["ImageMagick", "dm-core", "dm-validations"]
end
