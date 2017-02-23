require_relative 'lib/config'
require_relative 'lib/api/api'

Bundler.require(:default, Stats::Config.rack_environment)

Rollbar.configure do |config|
  config.access_token = Stats::Config.rollbar_token
  config.use_async = true
end

run Stats::Api::Api
