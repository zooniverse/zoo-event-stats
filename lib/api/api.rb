require 'sinatra'
require "sinatra/json"
require 'sinatra/cross_origin'
require_relative '../es/client'
require 'rollbar/middleware/sinatra'

module Stats
  module Api
    class Api < Sinatra::Base

      use Rollbar::Middleware::Sinatra

      register Sinatra::CrossOrigin

      get '/counts/?:type?/?:interval?\/?' do
        cross_origin :allow_origin => cors_origins,
          :allowmethods => [:get]
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

      def event_type_query(type)
        type_filter = { match: { event_type: type } }
        query = unless query_filters.empty?
          {
            bool: {
              must: [ type_filter, *query_filters ]
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

      def query_filters
        return @query_filters if @query_filters
        filters = { project_id: project_id, workflow_id: workflow_id, user_id: user_id }
        @query_filters = filters.map do |key, value|
          { match: { key => value } } if value
        end.compact
      end

      def project_id
        @project_id ||= safe(params[:project_id])
      end

      def workflow_id
        @worklfow_id ||= safe(params[:workflow_id])
      end

      def user_id
        @user_id ||= safe(params[:user_id])
      end

      def safe(input)
        if match = /\A(\d+)\z/.match(input)
          match[1]
        end
      end

      def search_client
        @search_client ||= Stats::Es::Client.new(:api)
      end

      def es_client
        @es_client ||= search_client.es_client
      end

      def cors_origins
        cors_origins = ENV["CORS_ORIGINS"] || '([a-z0-9-]+\.zooniverse\.org|field-book(-preview)?\.notesfromnature\.org)'
        /^https?:\/\/#{cors_origins}(:\d+)?$/
      end
    end
  end
end
