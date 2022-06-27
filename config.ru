require_relative 'lib/config'
require_relative 'lib/api/api'

Bundler.require(:default, :api, Stats::Config.rack_environment)

Rollbar.configure do |config|
  enabled = use_async = !Stats::Config.stats_development?
  config.access_token = Stats::Config.rollbar_token
  config.environment  = Stats::Config.stats_environment
  config.enabled      = enabled
  config.use_async    = use_async
  # do not report these errors to rollbar
  # https://docs.rollbar.com/docs/ruby#exception-level-filters
  config.exception_level_filters.merge!({
    'Sinatra::NotFound' => 'ignore',
    'Sinatra::BadRequest' => 'ignore'
  })
end

run Stats::Api::Api
