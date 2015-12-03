require_relative '../elasticsearch/client'

module Stats
  module Output
    class ElasticsearchWriter
      attr_reader :config, :client

      def initialize(es_config)
        @search_client = Stats::Elasticsearch::Client.new(:stats)
        @config = @search_client.config
        @client = @search_client.es_client
      end

      def health
        client.cluster.health
      end

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
        { _index: config[:index], _type: "event" }
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
