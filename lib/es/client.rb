# frozen_string_literal: true

require_relative '../config'
require_relative 'request_cache'
require 'elasticsearch'
require 'faraday_middleware/aws_signers_v4'
require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'active_support/cache'

module Stats
  module Es
    class Client

      attr_reader :service, :config, :es_client, :defaults

      def initialize(service)
        @service = service
        @config = defaults.merge(hosts: es_config["hosts"])
        @es_client = build_client
      end

      private

      def build_client
        cache_expires_in = ENV.fetch('CACHE_EXPIRY', 5).to_i
        cache = ActiveSupport::Cache::MemoryStore.new(
          expires_in: cache_expires_in.minutes
        )
        Elasticsearch::Client.new(config) do |f|
          f.use Stats::Es::RequestCache, cache

          # use the middleware signers when talking to the elastic
          unless dev_env?
            f.request :aws_signers_v4,
              credentials: Aws::Credentials.new(es_config["aws_key"], es_config["aws_secret"]),
              service_name: 'es',
              region: es_config["aws_region"]
          end

          # add es transport client request logging
          f.response(:logger, Logger.new($stdout, level: Logger::INFO)) if ENV.fetch('ES_TRANSPORT_LOGGING', false)
          # specify the underlying transport faraday adatper
          # https://github.com/elastic/elasticsearch-ruby/tree/1.x/elasticsearch-transport#transport-implementations
          f.adapter :typhoeus
        end
      end

      def client_env
        Stats::Config.service_env(service)
      end

      def dev_env?
        "#{client_env}" == Stats::Config::DEV_ENV
      end

      def defaults
        # reload host connections on failure
        # https://github.com/elastic/elasticsearch-ruby/tree/1.x/elasticsearch-transport#reloading-hosts
        @defaults = { log: es_logging?, index: 'zoo-events', reload_on_failure: true }
      end

      def es_config
        @es_config = Stats::Config.load_yaml('elasticsearch.yml', client_env)
      end

      def es_logging?
        !!ENV["ES_LOGGING"] || dev_env?
      end
    end
  end
end
