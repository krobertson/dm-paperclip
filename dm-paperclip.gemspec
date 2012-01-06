# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-paperclip}
  s.version = "2.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ken Robertson", "Mr Rogers"]
  s.date = %q{2011-06-28}
  s.email = %q{ken@invalidlogic.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "LICENSE", "Rakefile", "init.rb", "lib/dm-paperclip", "lib/dm-paperclip/attachment.rb", "lib/dm-paperclip/callback_compatability.rb", "lib/dm-paperclip/geometry.rb", "lib/dm-paperclip/interpolations.rb", "lib/dm-paperclip/iostream.rb", "lib/dm-paperclip/processor.rb", "lib/dm-paperclip/storage.rb", "lib/dm-paperclip/thumbnail.rb", "lib/dm-paperclip/upfile.rb", "lib/dm-paperclip/validations.rb", "lib/dm-paperclip.rb", "tasks/paperclip_tasks.rake", "test/attachment_test.rb", "test/fixtures", "test/fixtures/12k.png", "test/fixtures/50x50.png", "test/fixtures/5k.png", "test/fixtures/bad.png", "test/fixtures/text.txt", "test/geometry_test.rb", "test/helper.rb", "test/integration_test.rb", "test/iostream_test.rb", "test/paperclip_test.rb", "test/storage_test.rb", "test/thumbnail_test.rb"]
  s.homepage = %q{http://github.com/bunnymatic/dm-paperclip}
  s.rdoc_options = ["--line-numbers", "--inline-source"]
  s.require_paths = ["lib"]
  s.requirements = ["ImageMagick"]
  s.rubyforge_project = %q{dm-paperclip}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{File attachments as attributes for DataMapper, based on the original Paperclip by Jon Yurek at Thoughtbot}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<extlib>, [">= 0"])
      s.add_runtime_dependency(%q<datamapper>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<mocha>, ["= 0.9.8"])
      s.add_development_dependency(%q<aws-s3>, [">= 0"])
      s.add_development_dependency(%q<do_sqlite3>, [">= 0"])
    else
      s.add_dependency(%q<extlib>, [">= 0"])
      s.add_dependency(%q<datamapper>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<mocha>, ["= 0.9.8"])
      s.add_dependency(%q<aws-s3>, [">= 0"])
      s.add_dependency(%q<do_sqlite3>, [">= 0"])
    end
  else
    s.add_dependency(%q<extlib>, [">= 0"])
    s.add_dependency(%q<datamapper>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<mocha>, ["= 0.9.8"])
    s.add_dependency(%q<aws-s3>, [">= 0"])
    s.add_dependency(%q<do_sqlite3>, [">= 0"])
  end
end
