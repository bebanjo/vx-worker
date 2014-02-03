require 'airbrake'

Airbrake.configure do |config|
  if ENV['AIRBRAKE_API_KEY']
    config.api_key = ENV['AIRBRAKE_API_KEY']
    config.host    = ENV['AIRBRAKE_HOST']
    config.port    = ENV['AIRBRAKE_PORT'] || 80
    config.secure  = config.port == 443
  end
end
