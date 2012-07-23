require 'bundler'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'tempfile'

RUBY_VERSION >= '1.9.0' ? require("debugger") : require('ruby-debug')

Bundler.setup(:default, :development)

require "dm-migrations"
require "dm-validations"

ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
RAILS_ENV  = ENV['RAILS_ENV']

Object.const_set("Merb", Class.new())
Merb.class_eval do
  def self.root
    "#{ROOT}"
  end
  def self.env(str=nil)
    ENV['RAILS_ENV'] = str if str
    ENV['RAILS_ENV']
  end
end

$:.push File.expand_path("../lib", File.dirname(__FILE__))
require 'dm-paperclip'

ENV['RAILS_ENV'] ||= 'test'

FIXTURES_DIR = File.join(File.dirname(__FILE__), "fixtures") 
DataMapper.setup(:default, 'sqlite3::memory:')

unless defined?(Mash)
  class Mash < Hash
  end
end

Paperclip.configure do |config|
  config.root               = Merb.root # the application root to anchor relative urls (defaults to Dir.pwd)
  config.env                = Merb.env  # server env support, defaults to ENV['RACK_ENV'] or 'development'
  config.use_dm_validations = true      # validate attachment sizes and such, defaults to false
end

def rebuild_model options = {}
  Object.send(:remove_const, "Dummy") rescue nil
  Object.const_set("Dummy", Class.new())
  Dummy.class_eval do
    include DataMapper::Resource
    #include DataMapper::Validate
    # => include DataMapper::Validations
    include Paperclip::Resource
    property :id, ::DataMapper::Property::Serial
    property :other, String
    has_attached_file :avatar, options
  end
  DataMapper.auto_migrate!
end

def temporary_env(new_env)
  old_env = Merb.env
  Merb.env(new_env)
  yield
  Merb.env(old_env)
end
