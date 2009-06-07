require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'dm-core'
require 'dm-validations'
require 'dm-paperclip'

desc 'Default: run unit tests.'
task :default => [:clean, :test]

# Test tasks
desc 'Test the DM-Paperclip library.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'dm-paperclip'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

# Console 
desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r dm-validations -r dm-migrations -r ./lib/dm-paperclip.rb"
end

# Rdoc
desc 'Generate documentation for the paperclip plugin.'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'DM-Paperclip'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
 
# Code coverage
task :coverage do
  system("rm -fr coverage")
  system("rcov test/test_*.rb")
  system("open coverage/index.html")
end

# Clean house
desc 'Clean up files.'
task :clean do |t|
  FileUtils.rm_rf "doc"
  FileUtils.rm_rf "coverage"
  FileUtils.rm_rf "tmp"
  FileUtils.rm_rf "pkg"
  FileUtils.rm_rf "log"
end

spec = Gem::Specification.new do |s| 
  s.name              = "dm-paperclip"
  s.version           = Paperclip::VERSION
  s.author            = "Ken Robertson"
  s.email             = "ken@invalidlogic.com"
  s.homepage          = "http://invalidlogic.com/dm-paperclip/"
  s.platform          = Gem::Platform::RUBY
  s.summary           = "File attachments as attributes for DataMapper, based on the original Paperclip by Jon Yurek at Thoughtbot"
  s.files             = FileList["README.rdoc",
                                 "LICENSE",
                                 "Rakefile",
                                 "init.rb",
                                 "{lib,tasks,test}/**/*"].to_a
  s.require_path      = "lib"
  s.test_files        = FileList["test/**/test_*.rb"].to_a
  s.rubyforge_project = "dm-paperclip"
  s.has_rdoc          = true
  s.extra_rdoc_files  = ["README.rdoc"]
  s.rdoc_options << '--line-numbers' << '--inline-source'
  s.requirements << "ImageMagick"
  s.requirements << "data_mapper"
end
 
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end

WIN32 = (PLATFORM =~ /win32|cygwin/) rescue nil
SUDO  = WIN32 ? '' : ('sudo' unless ENV['SUDOLESS'])

desc "Install #{spec.name} #{spec.version}"
task :install => [ :package ] do
  sh "#{SUDO} gem install pkg/#{spec.name}-#{spec.version} --no-update-sources", :verbose => false
end

desc "Release new version"
task :release => [:test, :gem] do
  require 'rubygems'
  require 'rubyforge'
  r = RubyForge.new
  r.login
  r.add_release spec.rubyforge_project,
                spec.name,
                spec.version,
                File.join("pkg", "#{spec.name}-#{spec.version}.gem")
end
