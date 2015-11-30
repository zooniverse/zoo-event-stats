module Stats
  module Output
    class ElasticsearchWriter
      attr_reader :config, :client

      def initialize(es_config=nil)
        defaults = { log: true, index: 'zoo-events', type: 'event' }
        @config = defaults.merge(hosts: es_config["hosts"])
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

      def write(events)
        #TODO: look into making this no-op upserts instead of updates

        operations = events.map do |event|
          id = event_id(event)
          doc = doc_defaults.merge(data: event, _id: id, op_type: "create")
          {index: doc}
        end

        client.bulk body: operations
      end

      def doc_defaults
        { _index: config[:index], _type: config[:type] }
      end

      def event_id(event)
        if id = event["event_id"]
          id
        else
          Digest::SHA1.hexdigest("#{event}")
        end
      end
    end
  end
end
