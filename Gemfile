source 'http://rubygems.org'
gemspec

group :development, :test do
  gem 'dm-migrations'
  gem 'dm-validations'
  gem 'dm-sqlite-adapter'

  gem 'rake', '~> 0.8.7'
  gem 'shoulda'
  gem 'mocha'
  gem 'aws-sdk'
  gem 'simplecov', :require => false

  if RUBY_VERSION < '1.9'
    gem 'test-unit'
    gem 'ruby-debug'
  else
    gem 'ruby-debug19'
  end
end
