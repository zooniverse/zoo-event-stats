require_relative '../config'

module Stats
  module Api
    class ElasticsearchClient

      attr_reader :config, :es_client, :defaults

      def initialize
        @config = defaults.merge(hosts: es_config["hosts"])
        @es_client = Elasticsearch::Client.new(config)
      end

      private

      def defaults
        @defaults = { log: true, index: 'zoo-events' }
      end

      def es_config
        @es_config = Stats::Config.load_yaml('elasticsearch.yml', Stats::Config.rack_environment)
      end
    end
  end
end
