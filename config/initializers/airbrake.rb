Airbrake.configure do |config|
  config.api_key = "ENV['SENDGRID_USERNAME']"
end
