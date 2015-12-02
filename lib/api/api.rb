require 'sinatra'
require "sinatra/json"
require_relative 'elasticsearch_client'

module Stats
  module Api
    class Api < Sinatra::Base

      get '/counts/?:type?/?:interval?' do
        type = event_type(params[:type])
        interval = interval(params[:interval])
        json histogram_count(type, interval)
      end

      private

      def event_type(type)
        type || "classification"
      end

      def interval(interval)
        interval || "month"
      end

      def histogram_count(type, interval)
        es_client.search(
          index: search_client.config[:index],
          search_type: "count",
          body: event_type_query(type).merge(datetime_histogram(interval))
        )
      end

      # TODO: dont use wildcards for suffix matching as it's not efficient,
      # move this to matching on event_type when this is in
      # https://github.com/zooniverse/Panoptes/issues/1525
      def event_type_query(type)
        { query: { match: { event_type: type } } }
      end

      def datetime_histogram(interval)
        {
          "aggs": {
            "events_over_time": {
              "date_histogram": {
                "field": "event_time",
                "interval": interval
              }
            }
          }
        }
      end

      def search_client
        @search_client ||= Stats::Api::ElasticsearchClient.new
      end

      def es_client
        @es_client ||= search_client.es_client
      end
    end
  end
end
