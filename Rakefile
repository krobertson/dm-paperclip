# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'rake'
require 'rake/testtask'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options

    gem.name              = "dm-paperclip"
    gem.author            = "Ken Robertson"
    gem.email             = "ken@invalidlogic.com"
    gem.homepage          = "http://invalidlogic.com/dm-paperclip/"
    gem.platform          = Gem::Platform::RUBY
    gem.summary           = "File attachments as attributes for DataMapper, based on the original Paperclip by Jon Yurek at Thoughtbot"

    gem.requirements << "ImageMagick"
  end
  Jeweler::RubygemsDotOrgTasks.new
rescue LoadError
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
end

# Test tasks
desc 'Test the DM-Paperclip library.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'dm-paperclip'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Default: run unit tests.'
task :default => [:clean, :test]

# Console
desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r dm-validations -r dm-migrations -r ./lib/dm-paperclip.rb"
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
