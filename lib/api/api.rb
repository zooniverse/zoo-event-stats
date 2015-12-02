require 'sinatra'
require "sinatra/json"
require_relative 'elasticsearch_client'

module Stats
  module Api
    class Api < Sinatra::Base

      get '/counts/?:type?/?:interval?' do
        type = event_type(params[:type])
        interval = interval(params[:interval])
        query = event_type_query(type, params[:project_id])
          .merge(datetime_histogram(interval))
        results = histogram_count(query)
        json format_results(results)
      end

      private

      def format_results(results)
        if params.has_key?("es_format")
          results
        else
          results["aggregations"]
        end
      end

      def event_type(type)
        type || "classification"
      end

      def interval(interval)
        interval || "month"
      end

      def histogram_count(es_query)
        es_client.search(
          index: search_client.config[:index],
          search_type: "count",
          body: es_query
        )
      end

      def event_type_query(type, project_id=nil)
        type_filter = { match: { event_type: type } }
        query = if project_id
          {
            bool: {
              must: [ type_filter, { match: { project_id: project_id } } ]
            }
          }
        else
          type_filter
        end
        { query: query }
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
