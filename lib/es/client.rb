# frozen_string_literal: true

require_relative '../config'
require_relative 'request_cache'
require 'elasticsearch'
require 'faraday_middleware/aws_signers_v4'
require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'active_support/cache'
require 'active_support/notifications'

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
          if service == :api
            require 'circuitbox/faraday_middleware'
            # add ES query request caching - ensure this is before the circuit breakers
            # so we use the cached responses even when ES may be overloaded
            f.use Stats::Es::RequestCache, cache

            # add circuitbox middleware to handle ES transport failures
            # while load shedding to avoid a ES cluster issues
            f.use Circuitbox::FaradayMiddleware,
              # https://github.com/yammer/circuitbox/tree/v1.1.1#faraday
              open_circuit: lambda { |response|
                # nil -> connection could not be established, or failed very hard
                # 5xx -> non recoverable server error opposed to 4xx which are client errors
                # 429 -> too many requests / ES is overwhelemed with queries
                #        Elasticsearch::Transport::Transport::ServerError [429]
                #        {"error":"SearchPhaseExecutionException[Failed to execute phase [query], all shards failed; shardFailures ...." }
                response.status.nil? || (response.status >= 500 && response.status <= 599) || response.status == 429
              },
              # https://github.com/yammer/circuitbox/tree/v1.1.1#faraday
              circuit_breaker_options: {
                sleep_window: 60, # open the circuit / sleep for 1 minute before retrying https://github.com/yammer/circuitbox/blob/89aab2085dbf6f98ff7f8fc40a314103602f98da/lib/circuitbox/circuit_breaker.rb#L18
                volume_threshold: 1, # number of requests before calculating the error rates
              }
          end

          # use the AWS middleware signers when talking to the AWS ES cluster
          unless dev_env?
            f.request :aws_signers_v4,
              credentials: Aws::Credentials.new(es_config["aws_key"], es_config["aws_secret"]),
              service_name: 'es',
              region: es_config["aws_region"]
          end

          # add es transport client request logging only via $stderr
          # https://github.com/awslabs/amazon-kinesis-client-ruby/blob/96f149a4a2a5ac215f0cdb26252b0f68afb96d00/samples/sample_kcl.rb#L24-L27
          f.response(:logger, Logger.new($stderr, level: Logger::DEBUG)) if ENV.fetch('ES_TRANSPORT_LOGGING', false)
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
        # and timeout long running requests
        @defaults = { log: es_logging?, index: 'zoo-events', reload_on_failure: true, request_timeout: ENV.fetch('ES_REQUEST_TIMEOUT', '120').to_i }
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
