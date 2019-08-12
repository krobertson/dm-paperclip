# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "dm-paperclip"
  s.version = "2.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ken Robertson"]
  s.date = "2013-07-06"
  s.email = "ken@invalidlogic.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "dm-paperclip.gemspec",
    "lib/dm-paperclip.rb",
    "lib/dm-paperclip/attachment.rb",
    "lib/dm-paperclip/callbacks.rb",
    "lib/dm-paperclip/command_line.rb",
    "lib/dm-paperclip/ext/blank.rb",
    "lib/dm-paperclip/ext/class.rb",
    "lib/dm-paperclip/ext/compatibility.rb",
    "lib/dm-paperclip/ext/try_dup.rb",
    "lib/dm-paperclip/geometry.rb",
    "lib/dm-paperclip/interpolations.rb",
    "lib/dm-paperclip/iostream.rb",
    "lib/dm-paperclip/processor.rb",
    "lib/dm-paperclip/storage.rb",
    "lib/dm-paperclip/storage/filesystem.rb",
    "lib/dm-paperclip/storage/s3.rb",
    "lib/dm-paperclip/storage/s3/aws_library.rb",
    "lib/dm-paperclip/storage/s3/aws_s3_library.rb",
    "lib/dm-paperclip/style.rb",
    "lib/dm-paperclip/thumbnail.rb",
    "lib/dm-paperclip/upfile.rb",
    "lib/dm-paperclip/validations.rb",
    "lib/dm-paperclip/version.rb",
    "tasks/paperclip_tasks.rake",
    "test/attachment_test.rb",
    "test/command_line_test.rb",
    "test/fixtures/12k.png",
    "test/fixtures/50x50.png",
    "test/fixtures/5k.png",
    "test/fixtures/bad.png",
    "test/fixtures/s3.yml",
    "test/fixtures/text.txt",
    "test/fixtures/twopage.pdf",
    "test/fixtures/uppercase.PNG",
    "test/geometry_test.rb",
    "test/helper.rb",
    "test/integration_test.rb",
    "test/interpolations_test.rb",
    "test/iostream_test.rb",
    "test/paperclip_test.rb",
    "test/processor_test.rb",
    "test/storage_test.rb",
    "test/style_test.rb",
    "test/thumbnail_test.rb",
    "test/upfile_test.rb"
  ]
  s.homepage = "http://invalidlogic.com/dm-paperclip/"
  s.require_paths = ["lib"]
  s.requirements = ["ImageMagick"]
  s.rubygems_version = "1.8.24"
  s.summary = "File attachments as attributes for DataMapper, based on the original Paperclip by Jon Yurek at Thoughtbot"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, [">= 1.2.0"])
      s.add_runtime_dependency(%q<dm-validations>, [">= 1.2.0"])
      s.add_runtime_dependency(%q<dm-migrations>, [">= 1.2.0"])
      s.add_runtime_dependency(%q<extlib>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.0"])
      s.add_development_dependency(%q<yard>, "~> 0.9.20")
    else
      s.add_dependency(%q<dm-core>, [">= 1.2.0"])
      s.add_dependency(%q<dm-validations>, [">= 1.2.0"])
      s.add_dependency(%q<dm-migrations>, [">= 1.2.0"])
      s.add_dependency(%q<extlib>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.0"])
      s.add_dependency(%q<yard>, "~> 0.9.20")
    end
  else
    s.add_dependency(%q<dm-core>, [">= 1.2.0"])
    s.add_dependency(%q<dm-validations>, [">= 1.2.0"])
    s.add_dependency(%q<dm-migrations>, [">= 1.2.0"])
    s.add_dependency(%q<extlib>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.0"])
    s.add_dependency(%q<yard>, "~> 0.9.20")
  end
end
