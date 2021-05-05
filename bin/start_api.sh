#!/bin/bash -e

source "${BASH_SOURCE%/*}/configure.sh"

exec bundle exec puma -C config/puma.rb
