#!/bin/bash -e

source "${BASH_SOURCE%/*}/configure.sh"

exec bundle exec rake stream
