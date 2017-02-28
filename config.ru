require_relative 'lib/config'
require_relative 'lib/api/api'

Bundler.require(:default, Stats::Config.rack_environment)

Rollbar.configure do |config|
  enabled = use_async = !Stats::Config.stats_development?
  config.access_token = Stats::Config.rollbar_token
  config.environment  = Stats::Config.stats_environment
  config.enabled      = enabled
  config.use_async    = use_async
end

run Stats::Api::Api
