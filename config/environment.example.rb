
# This is an example config file for Open Plaques.
# You will need to copy this to environment.rb to run the application.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.active_record.default_timezone = :utc

  config.cache_classes = true

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  config.gem "json", :version => '1.4.5'

  # Used for testing...
  config.gem "shoulda", :version => '2.11.3'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  config.plugins = [ "restful-authentication", "usertext" ]

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_plaques_session',
    :secret      => '' # insert random key here!
  }

  # Site constants
  SITE_NAME = "Open Plaques"
  SITE_STATUS = "Alpha"

  # Flickr API key. Get yours here: http://www.flickr.com/services/api/keys/
  # FLICKR_KEY = ""
  # FLICKR_SECRET = ""

  # Yahoo Geocoding API key - used for geolocation controller
  # http://developer.yahoo.com/maps/rest/V1/geocode.html
  # YAHOO_GEOCODING_KEY = ""

  # Google Analytics ID (eg UA-353436-1).
  # GOOGLE_ANALYTICS_ID = ""
  config.active_record.observers = :plaque_observer


end
