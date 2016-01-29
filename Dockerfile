FROM zooniverse/ruby:2.2.1

MAINTAINER Campbell Allen

# Apt-get install dependencies
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install --no-install-recommends -y git supervisor && \
    apt-get clean

WORKDIR /zoo_stats

ADD ./Gemfile /zoo_stats/
ADD ./Gemfile.lock /zoo_stats/

RUN bundle install --without development test

EXPOSE 80

ADD ./ /zoo_stats

ADD supervisord.conf /etc/supervisor/conf.d/zoo_event_stats.conf

VOLUME /var/log/zoo-event-stats

ENTRYPOINT /zoo_stats/bin/start.sh
