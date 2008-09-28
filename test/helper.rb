require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'tempfile'

require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
begin
  require 'ruby-debug'
rescue LoadError
  puts "ruby-debug not loaded"
end

ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
RAILS_ENV  = ENV['RAILS_ENV']

Object.const_set("Merb", Class.new())
Merb.class_eval do
  def self.root
    "#{ROOT}"
  end
  def self.env
    ENV['RAILS_ENV']
  end
end

$LOAD_PATH << File.join(ROOT, 'lib')
$LOAD_PATH << File.join(ROOT, 'lib', 'dm-paperclip')

require File.join(ROOT, 'lib', 'dm-paperclip.rb')

ENV['RAILS_ENV'] ||= 'test'

FIXTURES_DIR = File.join(File.dirname(__FILE__), "fixtures") 
DataMapper.setup(:default, 'sqlite3::memory:')

unless defined?(Mash)
  class Mash < Hash
  end
end

def rebuild_model options = {}
  Object.send(:remove_const, "Dummy") rescue nil
  Object.const_set("Dummy", Class.new())
  Dummy.class_eval do
    include DataMapper::Resource
    include DataMapper::Validate
    include Paperclip::Resource
    property :id, Integer, :serial => true
    property :other, String
    has_attached_file :avatar, options
  end
  Dummy.auto_migrate!
end

def temporary_env(new_env)
  old_env = defined?(RAILS_ENV) ? RAILS_ENV : nil
  Object.const_set("RAILS_ENV", new_env)
  yield
  Object.const_set("RAILS_ENV", old_env)
end