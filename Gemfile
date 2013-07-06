source "https://rubygems.org"

gem "dm-core", ">= 1.2.0"
gem "dm-validations", ">= 1.2.0"
gem "dm-migrations", ">= 1.2.0"
gem "extlib", ">= 0"

group :development do
  gem "jeweler", "~> 1.8.0"
  gem "yard", "~> 0.8.1"

  gem "ruby-debug",           :platforms => :ruby_18
  gem "debugger", "~> 1.1.3", :platforms => [:ruby_19, :ruby_20]
end

group :test do
  gem "minitest"
  gem "shoulda", ">= 0"
  gem "mocha", "= 0.9.8", :require => false
  gem "aws-s3", ">= 0"
  gem "dm-sqlite-adapter", ">= 0"
  gem "sqlite3"
  gem "data_objects"
  gem "do_sqlite3", "~> 0.10.10"
  gem "database_cleaner", "~> 0.7.2"

  gem "rcov", "~> 1.0.0",      :platforms => :ruby_18
  gem "simplecov", "~> 0.6.4", :platforms => [:ruby_19, :ruby_20]
end
