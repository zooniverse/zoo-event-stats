# frozen_string_literal: true

env = ENV.fetch('RACK_ENV', 'development')
port = ENV.fetch('PORT', 80)
environment env
threads_count = ENV.fetch('PUMA_MAX_THREADS', 12).to_i
# === Non-Cluster mode (no worker / forking) ===
threads 1, threads_count
bind "tcp://0.0.0.0:#{port}"
