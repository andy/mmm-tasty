# Be sure to restart your web server when you modify this file.

RAILS_GEM_VERSION = '2.1.1' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = { :session_key => "tlogs-#{config.environment[0]}", :secret => "d77c6981c7f2b3eafedffb9b4c4bb7f9f52261a6891ebe1802e5dbb079275e84969f2ac070e3d24039aa686a10070f145fc6c6cfa3227e15327f7527df2b24e7" }

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.default_charset = "utf-8"

  config.gem 'image_science', :version => '>= 1.1.3'
  config.gem 'will_paginate', :version => '>= 2.2.2'
  config.gem 'coderay'
  config.gem 'sqlite3-ruby', :lib => 'sqlite3'
  config.gem 'ruby-openid', :lib => 'openid'
  config.gem 'memcache-client', :lib => 'memcache'

  # if you plan on using mysql, uncomment this
  # config.gem 'mysql'
end

require 'tasty_init'

ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_domain => '.mmm-tasty.ru')
ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| html_tag }

CGI::Session.expire_after 3.months
