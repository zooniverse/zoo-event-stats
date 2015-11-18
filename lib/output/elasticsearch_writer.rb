module Stats
  module Output
    class ElasticsearchWriter
      attr_reader :config, :client

      def initialize(es_config=nil)
        defaults = { log: true, index: 'zoo-events', type: 'event' }
        @config = defaults.merge(es_config)
        @client = Elasticsearch::Client.new(config)
      end

      def health
        client.cluster.health
      end

      # def index
      #   client.index index: config[:index], type: 'my-document', id: 1, body: { title: 'Test' }
      # end

      # def refresh_index
      #   client.indices.refresh index: config[:index]
      # end

      # def search
      #   client.search index: config["index"], body: { query: { match: { title: 'test' } } }
      # end

      def get(id)
        client.get doc_defaults.merge(id: id)
      end

      def write(event)
        id = event_id(event)
        doc = doc_defaults.merge(body: event, id: id)
        #TODO: look into making this no-op upserts instead of updates
        client.index(doc)
      end

      def doc_defaults
        { index: config[:index], type: config[:type] }
      end

      def event_id(event)
        #TODO: investigate if the event_id is unique across all panoptes / ouroboros event types
        Digest::SHA1.hexdigest("#{event}")
      end
    end
  end
end
