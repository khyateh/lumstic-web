Airbrake.configure do |config|  
  config.host = 'api.rollbar.com'
  config.secure = true
  config.api_key = ENV['AIRBRAKE_TOKEN']
end
