#!/bin/bash -ex

cd /zoo_stats

if [ -d "/zoo_stats_config/" ]
then
    ln -sf /zoo_stats_config/* ./config/
fi

if [ "$RACK_ENV" == "development" ]; then
  exec bundle exec foreman start
else
  exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
fi
