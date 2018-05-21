#!/bin/bash -ex

if [ -d "/zoo_stats/" ]
then
    cd /zoo_stats
fi

mkdir -p log/

if [ -d "/zoo_stats_config/" ]
then
    ln -sf /zoo_stats_config/* ./config/
fi

if [ -f "/run/secrets/environment" ]
then
    source /run/secrets/environment
fi

if [ "$RACK_ENV" == "production" ] || [ "$RACK_ENV" == "staging" ]; then
  exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
else
  exec bundle exec foreman start
fi
