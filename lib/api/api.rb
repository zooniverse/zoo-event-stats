require 'sinatra'
require "sinatra/json"
require_relative '../es/client'

module Stats
  module Api
    class Api < Sinatra::Base

      get '/counts/?:type?/?:interval?' do
        results = histogram_count
        json format_results(results)
      end

      get '/*' do
        json({ "health" => "ok" })
      end

      private

      def format_results(results)
        es_format? ? results : results["aggregations"]
      end

      def es_format?
        params.has_key?("es_format")
      end

      def event_type
        params[:type] || "classification"
      end

      def interval
        params[:interval] || "month"
      end

      def histogram_count
        es_client.search(
          index: search_client.config[:index],
          search_type: es_search_type,
          body: event_type_query(event_type).merge(datetime_histogram(interval))
        )
      rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
        message = es_format? ? e.message : "bad request, giving up."
        { "aggregations" => { error: message } }
      end

      def es_search_type
         params[:query_results] ? "query_then_fetch" : "count"
      end

      def event_type_query(type, project_id=params[:project_id])
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
        @search_client ||= Stats::Es::Client.new(:api)
      end

      def es_client
        @es_client ||= search_client.es_client
      end
    end
  end
end
