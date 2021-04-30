#!/bin/bash -e

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

