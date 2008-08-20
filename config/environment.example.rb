# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'development'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( action_cache acts_as_attachment acts_as_sphinx acts_as_taggable_on_steroids app_config dynamic_session_exp paginating_find request_routing simply_helpful white_list )
  
  config.action_controller.session = { :session_key => "tasty", :secret => "" }

  # The list of connection adapters to load. (By default, all connection adapters are loaded. You can set this to be just the adapter(s) you will use to reduce your application’s load time.)
  # config.connection_adapters = %W( mysql )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.default_charset = "utf-8"
  
  # See Rails::Configuration for more options  
  
  config.gem 'image_science', :version => '>= 1.1.3'
  config.gem 'will_paginate', :version => '>= 2.2.2'
end

require 'tasty_init'

# ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:tmpdir => File.join(RAILS_ROOT, '/tmp'))
ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_domain => '.mmm-tasty.ru')
ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| html_tag }

ActiveRecord::Errors::default_error_messages[:invalid] = 'неправильное значение'
ActiveRecord::Errors::default_error_messages[:empty] = 'не может быть пустым'
ActiveRecord::Errors::default_error_messages[:blank] = 'не может быть пустым'
ActiveRecord::Errors::default_error_messages[:too_long] = 'значение слишком длинное (не более %d символов)'
ActiveRecord::Errors::default_error_messages[:too_short] = 'значение слишком короткое (не меньше %d символов)'
ActiveRecord::Errors::default_error_messages[:taken] = 'такое значение уже используется'

CGI::Session.expire_after 3.months
