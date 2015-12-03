require_relative '../config'
require 'faraday_middleware/aws_signers_v4'

module Stats
  module Elasticsearch
    class Client

      attr_reader :service, :config, :es_client, :defaults

      def initialize(service)
        @service = service
        @config = defaults.merge(hosts: es_config["hosts"])
        @es_client = build_client
      end

      private

      def build_client
        if dev_env?
          ::Elasticsearch::Client.new(config)
        else
          ::Elasticsearch::Client.new(config) do |f|
            f.request :aws_signers_v4,
              credentials: Aws::Credentials.new(es_config["aws_key"], es_config["aws_secret"]),
              service_name: 'es',
              region: es_config["aws_region"]
            f.adapter  Faraday.default_adapter
          end
        end
      end

      def client_env
        Stats::Config.service_env(service)
      end

      def dev_env?
        "#{client_env}" == Stats::Config::DEV_ENV
      end

      def defaults
        @defaults = { log: dev_env?, index: 'zoo-events' }
      end

      def es_config
        @es_config = Stats::Config.load_yaml('elasticsearch.yml', client_env)
      end
    end
  end
end
