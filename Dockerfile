FROM ruby:2.3

MAINTAINER Campbell Allen

# Apt-get install dependencies
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install --no-install-recommends -y git supervisor default-jre-headless && \
    apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

WORKDIR /zoo_stats

ADD ./Gemfile /zoo_stats/
ADD ./Gemfile.lock /zoo_stats/

RUN bundle install --without development test

ADD ./Rakefile /zoo_stats/
RUN rake download_jars

EXPOSE 80

ADD ./ /zoo_stats

ADD supervisord.api.conf /etc/supervisor/conf.d/zoo_event_stats.conf
ADD supervisord.stream.conf /etc/supervisor/conf.d/zoo_event_stats_stream.conf

ENTRYPOINT /zoo_stats/bin/start.sh
