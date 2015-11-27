FROM zooniverse/ruby:2.2.1

MAINTAINER Campbell Allen

WORKDIR /zoo_stats

ADD ./Gemfile /zoo_stats/
ADD ./Gemfile.lock /zoo_stats/

#RUN bundle install --without development test
RUN bundle install

ADD ./ /zoo_stats

CMD exec bin/start
