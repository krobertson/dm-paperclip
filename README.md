# DataMapper Paperclip

[![Build Status](https://secure.travis-ci.org/krobertson/dm-paperclip.png?branch=master)](https://travis-ci.org/krobertson/dm-paperclip)

DM-Paperclip is a port of Thoughtbot's Paperclip plugin that works with DataMapper.
This plugin is fully compatible with the original ActiveRecord-oriented
Paperclip.  You can take an existing ActiveRecord database and use it with
DataMapper. The module also includes updates validation handling and automatic
including of the necessary 'property' fields into your model.

To use it within your models, you need to ensure the three database fields are
included.  They are `{name}_file_name`, `{name}_content_type`, and
`{name}_file_size`.  The first two are strings, the final `_file_size` column
is an integer. So if your user model has an avatar field, then you would add
`avatar_file_name`, `avatar_content_type`, and `avatar_file_size`.

As with the original Paperclip plugin, it allows processing of thumbnails at
the time the record is saved though ImageMagick. It processes the thumbnails
through the command-line application instead of using RMagick.

See the documentation for the `has_attached_file` method for options.

## Code

The code DM-Paperclip is available at Github:

```
git clone git://github.com/krobertson/dm-paperclip.git
```

It is regularly updated to keep in sync with the latest from Thoughtbot.

Releases are tagged within the repository and versioned the same as the
original model.  You can also get the latest release packaged as a gem through
Rubygems.org:

```
sudo gem install dm-paperclip
```

## Usage

In your model:

```ruby
class User
  include DataMapper::Resource
  include Paperclip::Resource
  property :id, Serial
  property :username, String
  has_attached_file :avatar,
                    :styles => { :medium => "300x300>",
                                 :thumb => "100x100>" }
end
```

You will need to add an initializer to configure Paperclip.  If on Rails, you
can add a `config/initializers/paperclip.rb`, and on Merb, you can use
`config/init.rb` and add it to the `Merb::BootLoader.after_app_loads` section.
You can also use environment configs, a rackup file, a Rake task, or whatever.

```ruby
Paperclip.configure do |config|
  config.root               = Rails.root # the application root to anchor relative urls (defaults to Dir.pwd)
  config.env                = Rails.env  # server env support, defaults to ENV['RACK_ENV'] or 'development'
  config.use_dm_validations = true       # validate attachment sizes and such, defaults to false
  config.processors_path    = 'lib/pc'   # relative path to look for processors, defaults to 'lib/paperclip_processors'
end
```

Your database will need to add four columns, `avatar_file_name` (varchar),
`avatar_content_type` (varchar), and `avatar_file_size` (integer), and
`avatar_updated_at` (datetime).  You can either add these manually, auto-
migrate, or use the following migration:

```ruby
migration( 1, :add_user_paperclip_fields ) do
up do
    modify_table :users do
      add_column :avatar_file_name, "varchar(255)"
      add_column :avatar_content_type, "varchar(255)"
      add_column :avatar_file_size, "integer"
      add_column :avatar_updated_at, "datetime"
    end
  end
  down do
    modify_table :users do
      drop_columns :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at
    end
  end
end
```

In your edit and new views:

```erb
<% form_for @user, { :action => url(:user), :multipart => true } do %>
  <%= file_field :name => 'avatar' %>
<% end %>
```

In your controller:

``` ruby
def create
  ...
  @user.avatar = params[:avatar]
end
```

In your show view:

```erb
<%= image_tag @user.avatar.url %>
<%= image_tag @user.avatar.url(:medium) %>
<%= image_tag @user.avatar.url(:thumb) %>
```

The following validations are available:

```ruby
validates_attachment_presence :avatar
validates_attachment_content_type :avatar, :content_type => "image/png"
validates_attachment_size :avatar, :in => 1..10240
validates_attachment_thumbnails :avatar
```

In order to use validations, you must have loaded the 'dm-validations' gem into
your app (available as a part of dm-more).  If the gem isn't loaded before
DM-Paperclip is loaded, the validation methods will be excluded.  You will also
need to include `DataMapper::Validate` into your model:

```ruby
class User
  include DataMapper::Resource
  include DataMapper::Validate
  include Paperclip::Resource
  property :id, Serial
  property :username, String
  has_attached_file :avatar,
                    :styles => { :medium => "300x300>",
                                 :thumb => "100x100>" }
  validates_attachment_size :avatar, :in => 1..5120
end
```
