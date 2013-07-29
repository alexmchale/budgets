Airbrake.configure do |config|
  config.api_key = '5b9d1e826a119363c7f2752f82f28a29'
  config.host    = 'errbit.anticlever.com'
  config.port    = 80
  config.secure  = config.port == 443
end
