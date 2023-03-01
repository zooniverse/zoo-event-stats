# frozen_string_literal: true

source 'https://rubygems.org'

gem 'activesupport'
gem 'elasticsearch', '~> 1.1.2'
gem 'faraday_middleware'
gem 'faraday_middleware-aws-signers-v4'
gem 'rake'
gem 'rollbar'
gem 'typhoeus'

group :api do
  gem 'circuitbox'
  gem 'puma'
  gem 'sinatra'
  gem 'sinatra-contrib'
  gem 'sinatra-cross_origin'
end

group :stream do
  gem 'aws-kclrb', '=1.0.0'
  gem 'geocoder'
  gem 'maxminddb'
  gem 'pusher'
end

group :development do
  gem 'pry'
end

group :test do
  gem 'minitest'
end
