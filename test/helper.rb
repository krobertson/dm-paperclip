require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'tempfile'

require 'data_mapper'
require 'dm-validations'
require 'dm-migrations'
begin
  require 'ruby-debug'
rescue LoadError
  puts "ruby-debug not loaded"
end

ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT

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

def rebuild_model options = {}
  DataMapper::Migration.new( 1, :drop_dummies_table ) do
    up do
      create_table :dummies do
        column :id, "integer", true
        column :other, "varchar(255)"
        column :avatar_file_name, "varchar(255)"
        column :avatar_content_type, "varchar(255)"
        column :avatar_file_size, "integer"
      end
    end
    down do
      drop_table :dummies
    end
    perform_down
    perform_up
  end

  Object.send(:remove_const, "Dummy") rescue nil
  Object.const_set("Dummy", Class.new())
  Dummy.class_eval do
    include DataMapper::Resource
    include DataMapper::Validate
    include Paperclip
#    include Paperclip::Validations
    property :id, Integer, :serial => true
    property :other, String
    has_attached_file :avatar, options
  end
end
