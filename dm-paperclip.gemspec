# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-paperclip}
  s.version = "2.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ken Robertson"]
  s.date = %q{2010-09-20}
  s.email = %q{ken@invalidlogic.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "LICENSE", "Rakefile", "init.rb", "lib/dm-paperclip.rb", "lib/dm-paperclip", "lib/dm-paperclip/geometry.rb", "lib/dm-paperclip/attachment.rb", "lib/dm-paperclip/storage.rb", "lib/dm-paperclip/iostream.rb", "lib/dm-paperclip/upfile.rb", "lib/dm-paperclip/callback_compatability.rb", "lib/dm-paperclip/interpolations.rb", "lib/dm-paperclip/validations.rb", "lib/dm-paperclip/thumbnail.rb", "lib/dm-paperclip/processor.rb", "tasks/paperclip_tasks.rake", "test/iostream_test.rb", "test/attachment_test.rb", "test/storage_test.rb", "test/thumbnail_test.rb", "test/integration_test.rb", "test/geometry_test.rb", "test/paperclip_test.rb", "test/fixtures", "test/fixtures/s3.yml", "test/fixtures/12k.png", "test/fixtures/text.txt", "test/fixtures/bad.png", "test/fixtures/50x50.png", "test/fixtures/5k.png", "test/helper.rb"]
  s.homepage = %q{http://invalidlogic.com/dm-paperclip/}
  s.rdoc_options = ["--line-numbers", "--inline-source"]
  s.require_paths = ["lib"]
  s.requirements = ["ImageMagick", "dm-core", "dm-validations"]
  s.rubyforge_project = %q{dm-paperclip}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{File attachments as attributes for DataMapper, based on the original Paperclip by Jon Yurek at Thoughtbot}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
