# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = 'dm-paperclip'
  s.version = '2.4.1'
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["README.rdoc", "LICENSE" ]
  s.summary = "File attachments as attributes for DataMapper, based on the original Paperclip by Jon Yurek at Thoughtbot"
  s.description = s.summary
  s.author = "Ken Robertson"
  s.email = "ken@invalidlogic.com"
  s.homepage = "http://github.com/krobertson/dm-paperclip"

  s.require_path = 'lib'
  s.files = Dir.glob("lib/**/*")
  s.requirements = ["ImageMagick", "dm-core", "dm-validations"]
end
