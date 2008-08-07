# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Enable the breakpoint server that script/breakpointer connects to
config.breakpoint_server = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true
config.log_level = :debug
config.action_view.debug_rjs                         = true

ActionController::Base.fragment_cache_store = :file_store, "/home/joe/tlogs/app-dev/tmp/cache"
#ActionController::Base.fragment_cache_store = :mem_cache_store, "127.0.0.1:3001"

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
