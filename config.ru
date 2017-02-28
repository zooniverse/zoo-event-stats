require_relative 'lib/config'
require_relative 'lib/api/api'

Bundler.require(:default, Stats::Config.rack_environment)

run Stats::Api::Api
