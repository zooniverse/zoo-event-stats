# frozen_string_literal: true

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

      configure :production, :staging, :development do
        enable :logging
        set :search_client, Stats::Es::Client.new(:api)
        set :elastic_search_client, Proc.new { settings.search_client.es_client }
      end

      get '/counts/?:type?/?:interval?\/?' do
        cross_origin :allow_origin => cors_origins,
          :allowmethods => [:get]
        results = histogram_count
        json format_results(results)
      end

      get '/' do
        json({ health: 'ok', revision: ENV['REVISION'] })
      end

      # sinkhole 404 & 400 responses
      error Sinatra::NotFound do
        [404, json({ message: 'Not Found' })]
      end

      error Sinatra::BadRequest do
        [404, json({ message: 'Bad Request' })]
      end

      # handle the 503 circuitbreaker errors
      error Elasticsearch::Transport::Transport::Errors::ServiceUnavailable do
        [503, json({ message: 'Service unavailable due to overload' })]
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
        settings.elastic_search_client.search(
          index: settings.search_client.config[:index],
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
        filters = { workflow_id: workflow_id, user_id: user_id }
        filters = filters.map do |key, value|
          { match: { key => value } } if value
        end
        # use terms query in combination with the match query
        # to search for multiple values for the project id field
        if project_ids
          filters << {
            terms: { project_id: project_ids }
          }
        end
        @query_filters = filters.compact
      end

      def project_ids
        return @project_ids if @project_ids

        if project_id = safe(params[:project_id])
          @project_ids = [ project_id.split(',') ].flatten.compact.uniq
        end
      end

      def workflow_id
        @worklfow_id ||= safe(params[:workflow_id])
      end

      def user_id
        @user_id ||= safe(params[:user_id])
      end

      def safe(input)
        if match = /\A([\d,]+)\z/.match(input)
          match[1]
        end
      end

      def cors_origins
        cors_origins = ENV["CORS_ORIGINS"] || '([a-z0-9-]+\.zooniverse\.org)'
        /^https?:\/\/#{cors_origins}(:\d+)?$/
      end
    end
  end
end
