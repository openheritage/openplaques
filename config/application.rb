require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rake/dsl_definition'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require *Rails.groups(:assets) if defined?(Bundler)

module Openplaques
  class Application < Rails::Application

    # --- INTERNATIONALISATION ---

    # Set the default locale to be British English
    config.i18n.default_locale = :"en-GB"

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation can not be found)
    config.i18n.fallbacks = true


    # -- ASSETS ---

    # Enable the asset pipeline for speedier loading
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Don't initialize on precompile as this doesn't work with Heroku
    config.assets.initialize_on_precompile = false

    # --- MISC ---

    # Set secret tokens from environment variables. In development, these can be specified
    # in the file .env (see example.env).
    config.secret_token = ENV['SECRET_TOKEN']
    config.secret_key_base = ENV['SECRET_KEY_BASE']


    # Set default time zone to be London (GMT/BST)
    config.time_zone = 'London'

    # Default encoding. Use UTF8 everywhere.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
  end
end
