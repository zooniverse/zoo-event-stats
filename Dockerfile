FROM ruby:2.6

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install --no-install-recommends -y git supervisor default-jre-headless && \
    apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
ARG RACK_ENV=staging
ARG REVISION=''
ENV REVISION=$REVISION

WORKDIR /zoo_stats

ADD ./Gemfile /zoo_stats/
ADD ./Gemfile.lock /zoo_stats/

RUN if [ "$RACK_ENV" = "staging" ]; then bundle install --without development test; else bundle install; fi

ADD ./Rakefile /zoo_stats/
RUN rake download_jars

ADD ./ /zoo_stats

ADD supervisord.api.conf /etc/supervisor/conf.d/zoo_event_stats.conf
ADD supervisord.stream.conf /etc/supervisor/conf.d/zoo_event_stats_stream.conf

CMD ["/zoo_stats/bin/start.sh"]
