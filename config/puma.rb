# frozen_string_literal: true

env = ENV.fetch('RACK_ENV', 'development')
port = ENV.fetch('PORT', 80)
environment env
bind "tcp://0.0.0.0:#{port}"
