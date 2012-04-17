# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-paperclip}
  s.version = "2.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ken Robertson"]
  s.date = %q{2011-04-25}
  s.email = %q{ken@invalidlogic.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "LICENSE", "Rakefile", "init.rb", "lib/dm-paperclip", "lib/dm-paperclip/thumbnail.rb", "lib/dm-paperclip/ext", "lib/dm-paperclip/ext/class.rb", "lib/dm-paperclip/ext/try_dup.rb", "lib/dm-paperclip/ext/blank.rb", "lib/dm-paperclip/ext/compatibility.rb", "lib/dm-paperclip/iostream.rb", "lib/dm-paperclip/command_line.rb", "lib/dm-paperclip/attachment.rb", "lib/dm-paperclip/style.rb", "lib/dm-paperclip/storage.rb", "lib/dm-paperclip/validations.rb", "lib/dm-paperclip/interpolations.rb", "lib/dm-paperclip/geometry.rb", "lib/dm-paperclip/processor.rb", "lib/dm-paperclip/version.rb", "lib/dm-paperclip/upfile.rb", "lib/dm-paperclip/callbacks.rb", "lib/dm-paperclip/storage", "lib/dm-paperclip/storage/filesystem.rb", "lib/dm-paperclip/storage/s3", "lib/dm-paperclip/storage/s3/aws_library.rb", "lib/dm-paperclip/storage/s3/aws_s3_library.rb", "lib/dm-paperclip/storage/s3.rb", "lib/dm-paperclip.rb", "tasks/paperclip_tasks.rake", "test/paperclip_test.rb", "test/attachment_test.rb", "test/command_line_test.rb", "test/integration_test.rb", "test/geometry_test.rb", "test/storage_test.rb", "test/helper.rb", "test/interpolations_test.rb", "test/iostream_test.rb", "test/thumbnail_test.rb", "test/style_test.rb", "test/upfile_test.rb", "test/fixtures", "test/fixtures/uppercase.PNG", "test/fixtures/12k.png", "test/fixtures/twopage.pdf", "test/fixtures/s3.yml", "test/fixtures/5k.png", "test/fixtures/50x50.png", "test/fixtures/bad.png", "test/fixtures/text.txt", "test/processor_test.rb"]
  s.homepage = %q{http://invalidlogic.com/dm-paperclip/}
  s.rdoc_options = ["--line-numbers", "--inline-source"]
  s.require_paths = ["lib"]
  s.requirements = ["ImageMagick", "dm-core", "dm-validations"]
  s.rubyforge_project = %q{dm-paperclip}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{File attachments as attributes for DataMapper, based on the original Paperclip by Jon Yurek at Thoughtbot}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
