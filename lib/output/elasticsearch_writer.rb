module Stats
  module Output
    class ElasticsearchWriter
      attr_reader :config, :client

      def initialize(es_config)
        defaults = { index: 'zoo-events', type: 'event' }
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
        operations = events.map do |event|
          formatter = EventFormatter.new(event)
          data = event.merge("event_type" => formatter.type, "event_source" => formatter.source)
          doc = doc_defaults.merge(data: data, _id: formatter.id, op_type: "create")
          {index: doc}
        end

        client.bulk body: operations
      end

      def doc_defaults
        { _index: config[:index], _type: config[:type] }
      end

      private

      class EventFormatter

        attr_reader :event

        def initialize(event)
          @event = event
        end

        def id
          if id = event["event_id"]
            id
          else
            Digest::SHA1.hexdigest("#{event}")
          end
        end

        def source
          event_type_details[0] || "unknown"
        end

        def type
          event_type_details[1] || event["event_type"]
        end

        private

        def event_type_details
          event["event_type"].split(".")
        end
      end
    end
  end
end
